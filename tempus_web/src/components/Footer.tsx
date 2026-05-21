export default function Footer() {
  return (
    <footer
      style={{
        position: 'relative',
        zIndex: 1,
        borderTop: '1px solid rgba(255, 255, 255, 0.08)',
        padding: '32px 16px',
        textAlign: 'center',
      }}
    >
      <div style={{ maxWidth: 600, margin: '0 auto' }}>
        <h2
          className="gradient-text"
          style={{
            fontSize: 28,
            fontWeight: 700,
            margin: '0 0 8px',
            letterSpacing: '-1px',
          }}
        >
          Tempus
        </h2>

        <p style={{ fontSize: 13, color: '#737373', margin: '0 0 20px', lineHeight: 1.6 }}>
          Feito para estudantes. Grátis.
          <br />
          Organize seu tempo. Conquiste seus objetivos.
        </p>

        <p style={{ fontSize: 12, color: '#4A4A4A', margin: 0 }}>
          © {new Date().getFullYear()} Tempus. Todos os direitos reservados.
        </p>
      </div>
    </footer>
  )
}
