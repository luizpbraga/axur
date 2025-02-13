# Array com os resultados
results=(
    "Texto mais profundo."
    "malformed HTML"
    "Este é o corpo."
    "malformed HTML"
    "Texto 1. AAA."
    ""
    "Este é um texto sem tags."
    ""
    "Texto mais profundo."
    "Título da página."
    "Profundidade máxima alcançada."
    "Apenas título."
    "Texto direto no body."
    "Primeiro texto profundo."
    "Apenas um nível."
    "malformed HTML"
    "malformed HTML"
    "malformed HTML"
    "malformed HTML"
    ""
    "malformed HTML"
    "malformed HTML"
    "O mais profundo possível."
    "malformed HTML"
    "O mais profundo possível."
    ""
)

url=http://localhost:8080

touch output

# Loop para escrever os resultados no arquivo output
for i in {0..25}; do
  # Definir a URL para cada página
  URL="${url}/${i}.html"
  
  # Escrever a URL no arquivo output
  echo "${URL}" >> output
  
  # Escrever o comando Java no arquivo output
  text=$(java HtmlAnalyzer "$URL")
  expected="${results[$i]}"
  
  if [ "$expected" == "$text" ]; then 
    echo "valores iquais"
  else 
    echo "valores nao iquais"
  fi

  # Escrever o resultado correspondente no arquivo output
  echo "$text|$expected" >> output
done
