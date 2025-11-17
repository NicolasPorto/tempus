using Auth0.AuthenticationApi.Models;
using Application.Repositories.Interfaces;
using Application.Services.Interfaces;
using Auth0.AuthenticationApi;
using Auth0.Core.Exceptions;
using Auth0.ManagementApi;
using Auth0.ManagementApi.Models;
using Domain.Base;
using Domain.Exceptions;
using Domain.Messaging;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using MySqlX.XDevAPI;
using System.Runtime.CompilerServices;

namespace Application.Services
{
    public class UserService :  IUserService
    {
        private readonly IConfiguration _config;
        private readonly IMemoryCache _cache;
        private readonly string _managementApiAudience;
        private readonly string _auth0Domain;
        private readonly string _m2mClientId;
        private readonly string _m2mClientSecret;

        private readonly IUserRepository _userRepository;

        public UserService(IConfiguration config, IUserRepository userRepository, IMemoryCache cache)
        {
            _config = config;
            _managementApiAudience = _config["AUTH0_CLIENT_AUDIENCE"];
            _auth0Domain = _config["AUTH0_CLIENT_DOMAIN"];
            _m2mClientId = _config["AUTH0_CLIENT_ID"];
            _m2mClientSecret = _config["AUTH0_CLIENT_SECRET"];
            _userRepository = userRepository;
            _cache = cache;
        }

        private string GetManagementApiToken()
        {
            const string cacheKey = "Auth0ManagementApiToken";

            if (_cache.TryGetValue(cacheKey, out string token))
            {
                return token;
            }

            var authApiClient = new AuthenticationApiClient(_auth0Domain);

            var tokenRequest = new ClientCredentialsTokenRequest
            {
                ClientId = _m2mClientId,
                ClientSecret = _m2mClientSecret,
                Audience = _managementApiAudience
            };

            var tokenResponse = authApiClient.GetTokenAsync(tokenRequest).GetAwaiter().GetResult();

            var cacheOptions = new MemoryCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = System.TimeSpan.FromSeconds(tokenResponse.ExpiresIn - 30)
            };
            _cache.Set(cacheKey, tokenResponse.AccessToken, cacheOptions);

            return tokenResponse.AccessToken;
        }

        private ManagementApiClient GetManagementClient()
        {
            string token = GetManagementApiToken();
            return new ManagementApiClient(token, _auth0Domain);
        }

        public void CreateUser(CreateUserRequest createUserRequest)
        {
            var userTempus = new Domain.Entities.User(createUserRequest);
            _userRepository.Insert(userTempus);
        }
    }
}
