package com.example;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import java.io.BufferedReader;
import java.io.StringReader;

public class HtmlAnalyzerTest {

    @Test
    public void testHtmlWithText() throws Exception {
        String html = """
            <html>
                <body>
                    <p>
                          Texto mais profundo
                    </p>
                </body>
            </html>
        """;
        String expected = "Texto mais profundo";

        try (BufferedReader reader = new BufferedReader(new StringReader(html))) {
            String result = HtmlAnalyzer.findDeepestText(reader);
            assertEquals(expected, result);
        }
    }

    @Test
    public void testMalformedHtml() throws Exception {
        String html = """
            <html>
                <head>
                    <title>Título</title>
                </head>
                <body>
                    <div>
                        <p>Texto</p>
                    </div>
                </body>
            </html>
        """;
        String expected = "malformed HTML";

        try (BufferedReader reader = new BufferedReader(new StringReader(html))) {
            String result = HtmlAnalyzer.findDeepestText(reader);
            assertEquals(expected, result);
        }
    }

    @Test
    public void testTextDirectlyInBody() throws Exception {
        String html = """
            <html>
                <body>
                    Texto direto no body
                </body>
            </html>
        """;
        String expected = "Texto direto no body";

        try (BufferedReader reader = new BufferedReader(new StringReader(html))) {
            String result = HtmlAnalyzer.findDeepestText(reader);
            assertEquals(expected, result);
        }
    }
}
