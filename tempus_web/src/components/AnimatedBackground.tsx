const orbs = [
  {
    style: { width: 700, height: 700, left: '10%', top: '15%' },
    color: 'rgba(90, 20, 200, 0.16)',
    animation: 'orb1 22s ease-in-out infinite',
  },
  {
    style: { width: 600, height: 600, left: '75%', top: '65%' },
    color: 'rgba(43, 127, 255, 0.13)',
    animation: 'orb2 28s ease-in-out infinite',
  },
  {
    style: { width: 500, height: 500, left: '60%', top: '20%' },
    color: 'rgba(172, 70, 255, 0.11)',
    animation: 'orb3 20s ease-in-out infinite',
  },
  {
    style: { width: 420, height: 420, left: '25%', top: '70%' },
    color: 'rgba(60, 30, 180, 0.10)',
    animation: 'orb4 25s ease-in-out infinite',
  },
]

export default function AnimatedBackground() {
  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 0,
        pointerEvents: 'none',
        overflow: 'hidden',
      }}
    >
      {orbs.map((orb, i) => (
        <div
          key={i}
          style={{
            position: 'absolute',
            borderRadius: '50%',
            background: `radial-gradient(circle, ${orb.color}, transparent 70%)`,
            filter: 'blur(80px)',
            willChange: 'transform',
            animation: orb.animation,
            ...orb.style,
            transform: 'translate(-50%, -50%)',
          }}
        />
      ))}
    </div>
  )
}
