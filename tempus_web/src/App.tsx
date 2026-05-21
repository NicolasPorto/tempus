import AnimatedBackground from './components/AnimatedBackground'
import Navbar from './components/Navbar'
import HeroSection from './components/HeroSection'
import StatsSection from './components/StatsSection'
import FeaturesSection from './components/FeaturesSection'
import AppPreviewSection from './components/AppPreviewSection'
import HowItWorksSection from './components/HowItWorksSection'
import Footer from './components/Footer'
import './index.css'

function App() {
  return (
    <div style={{ background: 'linear-gradient(to bottom right, #06040A, #0E0820, #1A1030)', minHeight: '100vh' }}>
      <AnimatedBackground />
      <Navbar />
      <HeroSection />
      <StatsSection />
      <FeaturesSection />
      <AppPreviewSection />
      <HowItWorksSection />
      <Footer />
    </div>
  )
}

export default App
