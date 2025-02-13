package main

import (
	"fmt"
	"log"
	"net/http"
)

type Info struct {
	html        string
	result      string
	description string
}

// HTML strings
var htmlPages = map[string]string{
	"0.html": `<html>
  <head>
    <title>
      Este é o título.
    </title>
  </head>
  <body>
    Este é o corpo.
    <div>
      <p>
        Texto mais profundo.
      </p>
    </div>
  </body>
</html>`,
	"1.html": `<html>
  <head>
    <title>
      Este é o título.
    </title>
  </head>
  <body>
    Este é o corpo.
    <div>
      <p>
        Texto mais profundo.
    </div>
  </body>
</html>`,
	"2.html": `<html>
  Este é o texto no nível mais alto.
  <body>
    Este é o corpo.
  </body>
</html>`,
	"3.html": `<html>
  Este é o texto no nível mais alto.
  <body>
    Este é o corpo, porem o par de tag esta errado.
  </p>
</html>`,
	"4.html": `<html>
  <body>
    <div>
      <p>
        Texto 1. AAA.
      </p>
      <p>
        Texto 2.
      </p>
    </div>
  </body>
</html>`,
	"5.html": ``,
	"6.html": `Este é um texto sem tags.`,
	"7.html": `<html>
  <head>
    <title>
    </title>
  </head>
  <body>
    <div>
    </div>
  </body>
</html>`,
	"8.html": `<html>

  <body>

    <div>
      <p>
        Texto mais profundo.
      </p>
    </div>

  </body>

</html>`,
	"9.html": `<html>
  <head>
    <title>
      Título da página.
    </title>
  </head>
  <body>
    <p>
    Texto de um parágrafo.
    </p>
  </body>
</html>`,
	"10.html": `<html>
  <body>
    <div>
      <span>
        <p>
          Profundidade máxima alcançada.
        </p>
      </span>
    </div>
  </body>
</html>`,
	"11.html": `<html>
  <head>
    <title>
      Apenas título.
    </title>
  </head>
</html>`,
	"12.html": `<html>
  <body>
    Texto direto no body.
  </body>
</html>`,
	"13.html": `<html>
  <body>
    <div>
      <p>
        Primeiro texto profundo.
      </p>
      <p>
        Segundo texto profundo.
      </p>
    </div>
  </body>
</html>`,
	"14.html": `<html>
  <body>
    <div>
      <p>
        Apenas um nível.
    </p>
  </div>
  </body>
</html>`,
	"15.html": `<html>
  <head>
    <title>
      Título correto.
  </head>
  <body>
    <p>Texto do corpo.</p>
  </body>
</html>`,
	"16.html": `<html>
  <head>
    <title>
      Título correto.
  </head>
  <body>
    Texto do corpo.
  </body>
</html>`,
	"17.html": `<html>
  <head>
    <title>
      Título correto.
    </title>
  </head>
  <body>
    <p>Texto do corpo.</p>
  </body>
</html>`,
	"18.html": `<html>
  <body>
    <div>
      <p>
        Texto não fechado.
    </div>
  </body>
</html>`,
	"19.html": `<html>
</html>`,
	"20.html": `<html></html>`,
	"21.html": `<html> Life is GOOOOD </html>`,
	"22.html": `<html>
  <body>
    <div>
      <p>
        <span>
          <strong>
            O mais profundo possível.
          </strong>
        </span>
      </p>
    </div>
  </body>
</html>`,
	"23.html": `<html>
  <head>
    <title>
      Título correto.
    </title>
  </head>
  <body>
    Texto do corpo
<html>
  <head>
    <title>
      Título correto.
    </title>
  </head>
    Texto do corpo
  </body>
</html>
  </body>
</html>`,
	"24.html": `<html>
  <body>
    <div>
      <p>
        <span>
          <strong>
          </strong>
          <strong>
            O mais profundo possível.
          </strong>
        </span>
      </p>
    </div>
  </body>
</html>`,
	"25.html": `<html>
  <body>
    <div>
      <p>
        <span>
          <strong>
          </strong>
        </span>
      </p>
    </div>
  </body>
</html>`,
}

// Handler to serve HTML pages
func pageHandler(w http.ResponseWriter, r *http.Request) {
	page := r.URL.Path[1:] // Extract file name from URL

	// Check if the page exists in the map
	if html, ok := htmlPages[page]; ok {
		// Serve the page content
		w.Header().Set("Content-Type", "text/html")
		fmt.Fprintf(w, html)
	} else {
		// If the page is not found, return a 404
		http.NotFound(w, r)
	}
}

func main() {
	// Route all requests to the page handler
	http.HandleFunc("/", pageHandler)

	// Start the server
	fmt.Println("Server started at http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
