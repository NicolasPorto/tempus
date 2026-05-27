import Navbar from './components/Navbar'
import SideNav from './components/SideNav'
import HeroSection from './components/HeroSection'
import StatsSection from './components/StatsSection'
import FeaturesSection from './components/FeaturesSection'
import AppPreviewSection from './components/AppPreviewSection'
import HowItWorksSection from './components/HowItWorksSection'
import TestimonialsSection from './components/TestimonialsSection'
import FAQSection from './components/FAQSection'
import Footer from './components/Footer'
import './index.css'

function App() {
  return (
    <div
      style={{
        minHeight: '100vh',
        background: `
          radial-gradient(ellipse 900px 700px at 10% 15%, rgba(100, 20, 220, 0.18), transparent),
          radial-gradient(ellipse 700px 600px at 85% 70%, rgba(43, 127, 255, 0.14), transparent),
          radial-gradient(ellipse 600px 500px at 65% 5%,  rgba(172, 70, 255, 0.10), transparent),
          radial-gradient(ellipse 500px 400px at 30% 80%, rgba(60, 30, 180, 0.10), transparent),
          #06040A
        `,
      }}
    >
      <Navbar />
      <SideNav />
      <HeroSection />
      <StatsSection />
      <FeaturesSection />
      <AppPreviewSection />
      <HowItWorksSection />
      <TestimonialsSection />
      <FAQSection />
      <Footer />
    </div>
  )
}

export default App
