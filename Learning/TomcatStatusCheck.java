import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

public class TomcatStatusCheck {
    public static void main(String[] args) throws IOException {
        URL url = new URL("http://localhost:8080");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        int responseCode = connection.getResponseCode();

        if (responseCode == 200) {
            System.out.println("Tomcat is running");
        } else {
            System.out.println("Tomcat is not running");
        }
    }
}
