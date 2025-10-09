#!/bin/bash

# Konvertiere Wiki Markdown zu HTML
echo "🔨 Building multi-page documentation site..."

# Erstelle docs Verzeichnis
mkdir -p _site/docs

# Funktion zum Konvertieren von Markdown zu HTML
convert_md_to_html() {
    local input_file=$1
    local output_file=$2
    local title=$3
    
    cat > "$output_file" << 'HTMLHEADER'
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PAGETITLE - Pokemon Essentials</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.5.0/github-markdown.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        .wrapper {
            display: flex;
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            min-height: 100vh;
        }
        .sidebar {
            width: 280px;
            background: #2d3748;
            color: white;
            padding: 30px 20px;
            position: sticky;
            top: 0;
            height: 100vh;
            overflow-y: auto;
        }
        .sidebar h2 {
            font-size: 1.5em;
            margin-bottom: 20px;
            color: #667eea;
        }
        .nav-group {
            margin-bottom: 25px;
        }
        .nav-group h3 {
            font-size: 0.9em;
            color: #a0aec0;
            text-transform: uppercase;
            margin-bottom: 10px;
        }
        .nav-link {
            display: block;
            color: #e2e8f0;
            text-decoration: none;
            padding: 8px 12px;
            border-radius: 6px;
            margin-bottom: 5px;
            transition: all 0.2s;
        }
        .nav-link:hover {
            background: #4a5568;
            color: white;
            transform: translateX(5px);
        }
        .nav-link.active {
            background: #667eea;
            color: white;
        }
        .content {
            flex: 1;
            padding: 40px;
            overflow-x: hidden;
        }
        .markdown-body {
            max-width: 900px;
        }
        .back-home {
            display: inline-block;
            padding: 10px 20px;
            background: #667eea;
            color: white !important;
            text-decoration: none;
            border-radius: 8px;
            margin-bottom: 20px;
            transition: all 0.2s;
        }
        .back-home:hover {
            background: #764ba2;
            transform: scale(1.05);
        }
        @media (max-width: 768px) {
            .wrapper { flex-direction: column; }
            .sidebar { width: 100%; height: auto; position: relative; }
        }
    </style>
</head>
<body>
    <div class="wrapper">
        <nav class="sidebar">
            <h2>📚 Documentation</h2>
            
            <div class="nav-group">
                <h3>Getting Started</h3>
                <a href="../index.html" class="nav-link">🏠 Home</a>
                <a href="home.html" class="nav-link">📖 Wiki Home</a>
                <a href="installation.html" class="nav-link">📥 Installation</a>
                <a href="faq.html" class="nav-link">❓ FAQ</a>
            </div>
            
            <div class="nav-group">
                <h3>Development</h3>
                <a href="cicd.html" class="nav-link">🤖 CI/CD Pipeline</a>
                <a href="https://github.com/99Problemsx/test-stuff/blob/main/CONTRIBUTING.md" class="nav-link" target="_blank">🤝 Contributing</a>
                <a href="https://github.com/99Problemsx/test-stuff/blob/main/WORKFLOWS.md" class="nav-link" target="_blank">⚙️ Workflows</a>
            </div>
            
            <div class="nav-group">
                <h3>Resources</h3>
                <a href="https://github.com/99Problemsx/test-stuff" class="nav-link" target="_blank">💻 GitHub Repo</a>
                <a href="https://github.com/99Problemsx/test-stuff/releases" class="nav-link" target="_blank">📦 Releases</a>
                <a href="https://github.com/99Problemsx/test-stuff/issues" class="nav-link" target="_blank">🐛 Issues</a>
            </div>
        </nav>
        
        <main class="content">
            <a href="../index.html" class="back-home">⬅ Back to Home</a>
            <article class="markdown-body">
HTMLHEADER
    
    # Ersetze Titel
    sed "s/PAGETITLE/$title/g" -i "$output_file"
    
    # Konvertiere Markdown (basic conversion)
    # In Produktion würde man einen Markdown-Parser wie pandoc verwenden
    sed 's/^# \(.*\)/<h1>\1<\/h1>/g' "$input_file" >> "$output_file"
    sed 's/^## \(.*\)/<h2>\1<\/h2>/g' -i "$output_file"
    sed 's/^### \(.*\)/<h3>\1<\/h3>/g' -i "$output_file"
    
    cat >> "$output_file" << 'HTMLFOOTER'
            </article>
        </main>
    </div>
</body>
</html>
HTMLFOOTER
}

# Kopiere Wiki-Dateien und konvertiere
if [ -d "wiki" ]; then
    echo "📄 Converting wiki pages..."
    
    # Home
    if [ -f "wiki/Home.md" ]; then
        cp wiki/Home.md _site/docs/home.md
        echo "✅ Copied Home"
    fi
    
    # Installation Guide
    if [ -f "wiki/Installation-Guide.md" ]; then
        cp wiki/Installation-Guide.md _site/docs/installation.md
        echo "✅ Copied Installation Guide"
    fi
    
    # CI/CD Pipeline
    if [ -f "wiki/CI-CD-Pipeline.md" ]; then
        cp wiki/CI-CD-Pipeline.md _site/docs/cicd.md
        echo "✅ Copied CI/CD Pipeline"
    fi
    
    # FAQ
    if [ -f "wiki/FAQ.md" ]; then
        cp wiki/FAQ.md _site/docs/faq.md
        echo "✅ Copied FAQ"
    fi
    
    echo "✅ Wiki pages ready for display!"
else
    echo "⚠️ Wiki directory not found, skipping..."
fi

echo "🎉 Build complete!"
