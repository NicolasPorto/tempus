import Navbar from './components/Navbar'
import HeroSection from './components/HeroSection'
import ProblemSection from './components/ProblemSection'
import FeaturesSection from './components/FeaturesSection'
import ShowcaseSection from './components/ShowcaseSection'
import VideoSection from './components/VideoSection'
import HowItWorksSection from './components/HowItWorksSection'
import AudienceSection from './components/AudienceSection'
import FAQSection from './components/FAQSection'
import Footer from './components/Footer'

export default function App() {
  return (
    <>
      <div className="aurora" aria-hidden="true">
        <i />
        <i />
        <i />
      </div>
      <div className="grain" aria-hidden="true" />
      <Navbar />
      <main className="relative">
        <HeroSection />
        <ProblemSection />
        <FeaturesSection />
        <ShowcaseSection />
        <VideoSection />
        <HowItWorksSection />
        <AudienceSection />
        <FAQSection />
      </main>
      <Footer />
    </>
  )
}
