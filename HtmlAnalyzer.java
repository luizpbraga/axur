import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Stack;

public class HtmlAnalyzer {
  
  private static final String MALFORMED_HTML_MSG = "malformed HTML";

  public static void main(String[] args) {
    if (args.length != 1) {
      System.out.println("Usage: java HtmlAnalyzer <URL>");
      return;
    }

    var urlString = args[0];
    try (var reader = fetchHtmlContent(urlString)) {
      var text = findDeepestText(reader);
      System.out.println(text);
    } catch (IOException e) {
      System.out.println("URL connection error");
    }
  }

  private static boolean isValidTag(String tag) {
    return tag.chars().noneMatch(c -> c == ' ' || c == '<' || c == '>' || c == '/');
  }

  private static BufferedReader fetchHtmlContent(String urlString) throws  IOException {
    var url = new URL(urlString);
    var connection = (HttpURLConnection) url.openConnection();
    connection.setRequestMethod("GET");
    connection.setConnectTimeout(5000);
    connection.setReadTimeout(5000);   
    return new BufferedReader(new InputStreamReader(connection.getInputStream()));
  }

  public static String findDeepestText(BufferedReader reader) throws IOException {
    var stack = new Stack<String>();
    var text = "";
    var maxDepth = -1; // initialized with -1 so we can capture text at depth = 0
    var line = "";

    while ((line = reader.readLine()) != null) {
      line = line.trim();

      // we don't like empty lines!
      if (line.isEmpty()) continue;

      // TAG CASE: '<' or '</'
      if (line.startsWith("<")) {
        // Tags must be closed, and text must not start with '<',
        // so we expect the line to end with '>'
        // Otherwise, we have a malformed line or an unclosed tag.
        if (!line.endsWith(">")) return MALFORMED_HTML_MSG;

        // CLOSING TAG (</)
        // When encountering a closing tag, we pop
        // the previously encountered tag from the stack.
        // If the stack is empty or the tags don't match,
        // the HTML is malformed.
        // I'm also assuming tags are well formatted
        if (line.startsWith("</")) {
          if (stack.isEmpty()) return MALFORMED_HTML_MSG;
          var prevTag = stack.pop();
          var currTag = line.substring(2, line.length() - 1);
          // if (!isValidTag(currTag)) return MALFORMED_HTML_MSG;
          if (!prevTag.equals(currTag)) return MALFORMED_HTML_MSG;
          continue;
        }

        // OPEN TAG (<) and not (/>)
        // At this point, we have a proper open tag
        //
        var currTag = line.substring(1, line.length() - 1);
        if (!isValidTag(currTag)) return MALFORMED_HTML_MSG;
        stack.push(currTag);
        continue;
      } 

      // TEXT CASE: This case handles text outside of tags.
      // We update the deepest text if the current depth
      // is greater than the previous maximum depth.
      var depth = stack.size();
      if (depth > maxDepth) {
        maxDepth = depth;
        text = line;
      }
    }

    if (!stack.isEmpty()) return MALFORMED_HTML_MSG;

    return text;
  }
}
