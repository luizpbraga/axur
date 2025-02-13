const std = @import("std");
// Note: The lifetime of the HTML input is the same as the result of this function.
fn deepestTxt(html: []const u8) ![]const u8 {
    const allocator = std.heap.page_allocator;

    var tags: std.ArrayList([]const u8) = .init(allocator);
    defer tags.deinit();

    const malformed_html: []const u8 = "malformed HTML";
    // The final result
    var deepest_text: []const u8 = "";
    // Depth counter
    var depth: usize = 0;
    // Default value is -1; with no tags, we capture raw text.
    var max_depth: isize = 0;

    var lines = std.mem.splitScalar(u8, html, '\n');
    while (lines.next()) |line| {
        const sline = std.mem.trim(u8, line, " ");

        if (sline.len == 0) continue;

        // TAG CASE (<) or (</)
        if (std.mem.startsWith(u8, sline, "<")) {
            // Tags must be closed, and text must not start with '<',
            // so we expect the line to end with '>'
            // Otherwise, we have a malformed line or an unclosed tag.
            if (!std.mem.endsWith(u8, sline, ">")) {
                return malformed_html;
            }

            // CLOSING TAG (</)
            // When encountering a closing tag, we pop
            // the previously encountered tag from the stack.
            // If the stack is empty or the tags don't match,
            // the HTML is malformed.
            if (std.mem.startsWith(u8, sline, "</")) {
                const prev_tag = tags.pop() orelse {
                    return malformed_html;
                };
                const curr_tag = sline[2 .. sline.len - 1];
                if (!std.mem.eql(u8, prev_tag, curr_tag)) {
                    return malformed_html;
                }
                continue;
            }

            // OPEN TAG (<) and not (/>)
            // At this point, we have a properly closed opening tag.
            const tag = sline[1 .. sline.len - 1];
            try tags.append(tag);
            continue;
        }

        // TEXT CASE: This case handles text outside of tags.
        // *UNRECHABLE CODE FOR TAGS*
        // We update the deepest text if the current depth
        // is greater than the previous maximum depth.
        depth = tags.items.len;
        if (depth > max_depth) {
            max_depth, deepest_text = .{ @intCast(depth), sline };
        }
    }

    // If there are any unclosed tags, the HTML is malformed.
    if (tags.items.len != 0) {
        return malformed_html;
    }

    return deepest_text;
}

const TestCase = struct {
    html: []const u8, // Field for the HTML content
    result: []const u8, // Field for the expected result
    description: []const u8, // Explanation for why the test will pass or fail
};

const testCases = [_]TestCase{
    .{
        .html =
        \\<html>
        \\  <head>
        \\    <title>
        \\      Este é o título.
        \\    </title>
        \\  </head>
        \\  <body>
        \\    Este é o corpo.
        \\    <div>
        \\      <p>
        \\        Texto mais profundo.
        \\      </p>
        \\    </div>
        \\  </body>
        \\</html>
        ,
        .result = "Texto mais profundo.",
        .description = "The deepest text is within the <p> tag inside the <div>, which is nested within the <body> tag.",
    },
    .{
        .html =
        \\<html>
        \\  <head>
        \\    <title>
        \\      Este é o título.
        \\    </title>
        \\  </head>
        \\  <body>
        \\    Este é o corpo.
        \\    <div>
        \\      <p>
        \\        Texto mais profundo.
        \\    </div>
        \\  </body>
        \\</html>
        ,
        .result = "malformed HTML",
        .description = "The <div> tag is not properly closed, making the HTML malformed.",
    },
    .{
        .html =
        \\<html>
        \\  Este é o texto no nível mais alto.
        \\  <body>
        \\    Este é o corpo.
        \\  </body>
        \\</html>
        ,
        .result = "Este é o corpo.",
        .description = "The deepest text is within the <body> tag, as the text on the top level is outside of any tags.",
    },
    .{
        .html =
        \\<html>
        \\  Este é o texto no nível mais alto.
        \\  <body>
        \\    Este é o corpo, porem o par de tag esta errado.
        \\  </p>
        \\</html>
        ,
        .result = "malformed HTML",
        .description = "The <body> tag is improperly closed with a </p> tag, causing the HTML to be malformed.",
    },
    .{
        .html =
        \\<html>
        \\  <body>
        \\    <div>
        \\      <p>
        \\        Texto 1. AAA.
        \\      </p>
        \\      <p>
        \\        Texto 2.
        \\      </p>
        \\    </div>
        \\  </body>
        \\</html>
        ,
        .result = "Texto 1. AAA.",
        .description = "The deepest text is in the first <p> tag, as the text within <div> is nested, but the first <p> is the deepest.",
    },
    .{
        .html = "",
        .result = "",
        .description = "The HTML content is empty, so the result is also empty.",
    },
    .{
        .html = "Este é um texto sem tags.",
        .result = "Este é um texto sem tags.",
        .description = "There are no tags, so the entire string is considered as the deepest text.",
    },
    .{
        .html =
        \\<html>
        \\  <head>
        \\    <title>
        \\    </title>
        \\  </head>
        \\  <body>
        \\    <div>
        \\    </div>
        \\  </body>
        \\</html>
        ,
        .result = "",
        .description = "The body contains only empty tags, so there is no text to extract.",
    },
    .{
        .html =
        \\<html>
        \\
        \\  <body>
        \\
        \\    <div>
        \\      <p>
        \\        Texto mais profundo.
        \\      </p>
        \\    </div>
        \\
        \\  </body>
        \\
        \\</html>
        ,
        .result = "Texto mais profundo.",
        .description = "The deepest text is within the <p> tag, which is inside a <div> tag nested in the <body> tag.",
    },
    .{
        .html =
        \\<html>
        \\  <head>
        \\    <title>
        \\      Título da página.
        \\    </title>
        \\  </head>
        \\  <body>
        \\    <p>
        \\    Texto de um parágrafo.
        \\    </p>
        \\  </body>
        \\</html>
        ,
        .result = "Título da página.",
        .description = "The title is the deepest text, as it is inside the <title> tag within the <head> section.",
    },
    .{
        .html =
        \\<html>
        \\  <body>
        \\    <div>
        \\      <span>
        \\        <p>
        \\          Profundidade máxima alcançada.
        \\        </p>
        \\      </span>
        \\    </div>
        \\  </body>
        \\</html>
        ,
        .result = "Profundidade máxima alcançada.",
        .description = "The deepest text is inside the <p> tag, nested inside <span>, which is further nested inside <div>.",
    },
    .{
        .html =
        \\<html>
        \\  <head>
        \\    <title>
        \\      Apenas título.
        \\    </title>
        \\  </head>
        \\</html>
        ,
        .result = "Apenas título.",
        .description = "The deepest text is inside the <title> tag, which is the only tag containing text.",
    },
    .{
        .html =
        \\<html>
        \\  <body>
        \\    Texto direto no body.
        \\  </body>
        \\</html>
        ,
        .result = "Texto direto no body.",
        .description = "The deepest text is directly within the <body> tag, as there are no other nested elements.",
    },
    .{
        .html =
        \\<html>
        \\  <body>
        \\    <div>
        \\      <p>
        \\        Primeiro texto profundo.
        \\      </p>
        \\      <p>
        \\        Segundo texto profundo.
        \\      </p>
        \\    </div>
        \\  </body>
        \\</html>
        ,
        .result = "Primeiro texto profundo.",
        .description = "The deepest text is within the first <p> tag inside the <div> tag.",
    },
    .{
        .html =
        \\<html>
        \\  <body>
        \\    <div>
        \\      <p>
        \\        Apenas um nível.
        \\    </p>
        \\  </div>
        \\  </body>
        \\</html>
        ,
        .result = "Apenas um nível.",
        .description = "There is only one level of nested tags, so the text in the <p> tag is the deepest.",
    },
    .{
        .html =
        \\<html>
        \\  <head>
        \\    <title>
        \\      Título correto.
        \\  </head>
        \\  <body>
        \\    <p>Texto do corpo.</p>
        \\  </body>
        \\</html>
        ,
        .result = "malformed HTML",
        .description = "The <title> tag is missing its closing tag, making the HTML malformed.",
    },
    .{
        .html =
        \\<html>
        \\  <head>
        \\    <title>
        \\      Título correto.
        \\  </head>
        \\  <body>
        \\    Texto do corpo.
        \\  </body>
        \\</html>
        ,
        .result = "malformed HTML",
        .description = "The <body> tag is missing its closing tag, causing the HTML to be malformed.",
    },
    .{
        .html =
        \\<html>
        \\  <head>
        \\    <title>
        \\      Título correto.
        \\    </title>
        \\  </head>
        \\  <body>
        \\    <p>Texto do corpo.</p>
        \\  </body>
        \\</html>
        ,
        .result = "malformed HTML",
        .description = "The <body> tag is improperly closed with a </p> tag, causing the HTML to be malformed.",
    },
    .{
        .html =
        \\<html>
        \\  <body>
        \\    <div>
        \\      <p>
        \\        Texto não fechado.
        \\    </div>
        \\  </body>
        \\</html>
        ,
        .result = "malformed HTML",
        .description = "The <p> tag is not closed, causing the HTML to be malformed.",
    },
    .{
        .html =
        \\<html>
        \\</html>
        ,
        .result = "",
        .description = "The HTML only contains the opening and closing <html> tags without any text, so the result is an empty string.",
    },
    .{
        .html = "<html></html>",
        .result = "malformed HTML",
        .description = "More then one elements in the same line, making it malformed.",
    },

    .{
        .html = "<html> Life is GOOOOD </html>",
        .result = "malformed HTML",
        .description = "More then one elements in the same line, making it malformed.",
    },
    .{
        .html =
        \\<html>
        \\  <body>
        \\    <div>
        \\      <p>
        \\        <span>
        \\          <strong>
        \\            O mais profundo possível.
        \\          </strong>
        \\        </span>
        \\      </p>
        \\    </div>
        \\  </body>
        \\</html>
        ,
        .result = "O mais profundo possível.",
        .description = "The deepest text is inside the <strong> tag, nested inside <span>, <p>, <div>, and <body>.",
    },
    .{
        .html =
        \\<html>
        \\  <head>
        \\    <title>
        \\      Título correto.
        \\    </title>
        \\  </head>
        \\  <body>
        \\    Texto do corpo
        \\<html>
        \\  <head>
        \\    <title>
        \\      Título correto.
        \\    </title>
        \\  </head>
        \\    Texto do corpo
        \\  </body>
        \\</html>
        \\  </body>
        \\</html>
        ,
        .result = "malformed HTML",
        .description = "The <html> tags are nested improperly, making the HTML malformed.",
    },
    .{
        .html =
        \\<html>
        \\  <body>
        \\    <div>
        \\      <p>
        \\        <span>
        \\          <strong>
        \\          </strong>
        \\          <strong>
        \\            O mais profundo possível.
        \\          </strong>
        \\        </span>
        \\      </p>
        \\    </div>
        \\  </body>
        \\</html>
        ,
        .result = "O mais profundo possível.",
        .description = "The deepest text is inside the <strong> tag, nested inside <span>, <p>, <div>, and <body>.",
    },
    .{
        .html =
        \\<html>
        \\  <body>
        \\    <div>
        \\      <p>
        \\        <span>
        \\          <strong>
        \\          </strong>
        \\        </span>
        \\      </p>
        \\    </div>
        \\  </body>
        \\</html>
        ,
        .result = "",
        .description = "The deepest text is inside the <strong> tag, nested inside <span>, <p>, <div>, and <body>.",
    },
};

// Test
test {
    for (testCases) |t| {
        const txt = try deepestTxt(t.html);
        try std.testing.expectEqualStrings(t.result, txt);
    }
}
