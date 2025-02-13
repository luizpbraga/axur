import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Stack;

public class HtmlAnalyzer {

  // Constant for the malformed HTML message
  private static final String MALFORMED_HTML_MSG = "malformed HTML";

  public static void main(String[] args) {
    // Check if the URL argument is provided
    if (args.length != 1) {
      System.out.println("Usage: java HtmlAnalyzer <URL>");
      return;
    }

    // Get the URL from the command line arguments
    var urlString = args[0];
    try (var reader = fetchHtmlContent(urlString)) {
      // Find and print the deepest text in the HTML
      var text = findDeepestText(reader);
      System.out.println(text);
    } catch (IOException e) {
      // Handle URL connection errors
      System.out.println("URL connection error");
    }
  }

  /**
   * Checks if a tag is valid.
   * A valid tag should not contain spaces, '<', '>', or '/'.
   *
   * @param tag The tag to validate.
   * @return true if the tag is valid, false otherwise.
   */
  private static boolean isValidTag(String tag) {
    return tag.chars().noneMatch(c -> c == ' ' || c == '<' || c == '>' || c == '/');
  }

  /**
   * Fetches the HTML content from the given URL.
   *
   * @param urlString The URL to fetch the HTML content from.
   * @return A BufferedReader for reading the HTML content.
   * @throws IOException If an I/O error occurs while connecting to the URL.
   */
  private static BufferedReader fetchHtmlContent(String urlString) throws IOException {
    var url = new URL(urlString);
    var connection = (HttpURLConnection) url.openConnection();
    connection.setRequestMethod("GET");
    connection.setConnectTimeout(5000); // Set connection timeout to 5 seconds
    connection.setReadTimeout(5000);    // Set read timeout to 5 seconds
    return new BufferedReader(new InputStreamReader(connection.getInputStream()));
  }

  /**
   * Finds the deepest text in the HTML content.
   *
   * @param reader A BufferedReader for reading the HTML content.
   * @return The deepest text found in the HTML, or "malformed HTML" if the HTML is invalid.
   * @throws IOException If an I/O error occurs while reading the HTML content.
   */
  public static String findDeepestText(BufferedReader reader) throws IOException {
    var stack = new Stack<String>(); // Stack to keep track of open tags
    var text = "";                   // Variable to store the deepest text
    var line = "";                   // Variable to store the current line being read
    var maxDepth = -1;               // Variable to store the maximum depth encountered

    // Read the HTML content line by line
    while ((line = reader.readLine()) != null) {
      line = line.trim();

      // Skip empty lines
      if (line.isEmpty()) continue;

      // TAG CASE: Check if the line starts with '<'
      if (line.startsWith("<")) {
        // Tags must be properly closed, so the line must end with '>'
        // If not, the HTML is malformed
        if (!line.endsWith(">")) return MALFORMED_HTML_MSG;

        // CLOSING TAG: Check if the line starts with '</'
        if (line.startsWith("</")) {
          // If the stack is empty, there's no matching opening tag
          if (stack.isEmpty()) return MALFORMED_HTML_MSG;

          // Pop the last opened tag from the stack
          var prevTag = stack.pop();

          // Extract the current tag name (remove '</' and '>')
          var currTag = line.substring(2, line.length() - 1);
        
          // Validate the tag
          if (!isValidTag(currTag)) return MALFORMED_HTML_MSG;

          // Check if the current tag matches the last opened tag
          if (!prevTag.equals(currTag)) return MALFORMED_HTML_MSG;

          // Continue to the next line
          continue;
        }

        // OPENING TAG: Extract the tag name (remove '<' and '>')
        var currTag = line.substring(1, line.length() - 1);

        // Validate the tag
        if (!isValidTag(currTag)) return MALFORMED_HTML_MSG;

        // Push the tag onto the stack
        stack.push(currTag);
        continue;
      }

      // TEXT CASE: The line contains text outside of tags
      // Calculate the current depth (number of open tags)
      var depth = stack.size();
      // Update the deepest text if the current depth is greater than the maximum depth
      if (depth > maxDepth) {
        maxDepth = depth;
        text = line;
      }
    }

    // If the stack is not empty, there are unclosed tags
    if (!stack.isEmpty()) return MALFORMED_HTML_MSG;

    // Return the deepest text found
    return text;
  }
}
