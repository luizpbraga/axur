# HtmlAnalyzer

HtmlAnalyzer is a Java application that analyzes the structure of an HTML document and retrieves the deepest text content based on the nesting level of HTML tags. It is designed to handle well-formed HTML documents and can detect malformed HTML structures.

---

## Features

- **Deepest Text Extraction**: Identifies the text content at the deepest nesting level in the HTML structure.
- **Malformed HTML Detection**: Detects and reports malformed HTML, such as unclosed tags or mismatched tags.
- **URL Support**: Fetches HTML content directly from a provided URL.
- **Lightweight**: Uses only standard Java libraries, with no external dependencies.

---

## Requirements

- **Java Development Kit (JDK) 17**: The application is built using Java 17.
- **Command Line Interface (CLI)**: The application is executed via the command line.

---

## Usage

### 1. Compile the Application

Navigate to the directory containing the `HtmlAnalyzer.java` file and compile it using the following command:

```bash
javac HtmlAnalyzer.java
```

### 2. Run the Application

Run the application by providing a URL as an argument. For example:

```bash
java HtmlAnalyzer http://example.com/sample.html
```

### 3. Output

The application will output one of the following:
- The deepest text content found in the HTML.
- `malformed HTML` if the HTML structure is invalid.
- `URL connection error` if the URL cannot be accessed.

---

## How It Works

The application processes the HTML content line by line, following these steps:

1. **Fetch HTML Content**:
   - The HTML content is fetched from the provided URL using an HTTP connection.

2. **Process Each Line**:
   - Each line is trimmed and checked for empty lines.
   - Lines starting with `<` are treated as tags (either opening or closing).
   - Lines without `<` are treated as text content.

3. **Track Nesting Depth**:
   - A stack is used to track the nesting level of HTML tags.
   - For each opening tag (`<tag>`), the tag is pushed onto the stack.
   - For each closing tag (`</tag>`), the tag is popped from the stack and validated.

4. **Identify Deepest Text**:
   - The text content at the deepest nesting level is identified and returned.

5. **Validate HTML Structure**:
   - If the stack is not empty after processing all lines, the HTML is considered malformed.

---

## Examples

### Example 1: Well-Formed HTML

#### Input (URL):
```
http://example.com/sample.html
```

#### HTML:
```html
<html>
  <head>
    <title>
      This is the title.
    </title>
  </head>
  <body>
    This is the body.
    <div>
      <p>
        Deepest text.
      </p>
    </div>
  </body>
</html>
```

#### Output:
```
Deepest text.
```

---

### Example 2: Malformed HTML

#### Input (URL):
```
http://example.com/malformed.html
```

#### HTML:
```html
<html>
  <head>
    <title>
      This is the title.
    </title>
  </head>
  <body>
    This is the body.
    <div>
      <p>
        Deepest text.
      </span> <!-- Mismatched closing tag -->
    </div>
  </body>
</html>
```

#### Output:
```
malformed HTML
```

---

### Example 3: URL Connection Error

#### Input (URL):
```
http://nonexistent-url.com
```

#### Output:
```
URL connection error
```

---

## Code Structure

The project consists of a single Java file:

- **`HtmlAnalyzer.java`**: Contains the main logic for fetching HTML content, processing it, and identifying the deepest text.

---

## Author

- **Your Name**
- GitHub: [luizpbraga](https://github.com/luizpbraga)
- Email: portilho.braga@gmail.com

---

## Acknowledgments

- Thanks to [Axur](https://axur.com) for the technical challenge that inspired this project.
---
