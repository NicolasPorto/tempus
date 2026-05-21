import AnimatedBackground from './components/AnimatedBackground'
import HeroSection from './components/HeroSection'
import FeaturesSection from './components/FeaturesSection'
import HowItWorksSection from './components/HowItWorksSection'
import Footer from './components/Footer'
import './index.css'

function App() {
  return (
    <div style={{ background: 'linear-gradient(to bottom right, #06040A, #0E0820, #1A1030)', minHeight: '100vh' }}>
      <AnimatedBackground />
      <HeroSection />
      <FeaturesSection />
      <HowItWorksSection />
      <Footer />
    </div>
  )
}

export default App
