import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientConfig {
  // TODO: Substitua pelos valores do seu projeto no app.supabase.com
  static const String url = 'https://vqycgorhuffnjrxyxfsx.supabase.co';
  static const String anonKey = 'sb_publishable_ieyfXiqSrUU3q55RBKY6ZQ_rSVTBht3';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
