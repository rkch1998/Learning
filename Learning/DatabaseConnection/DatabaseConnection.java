
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection{

    public static void main(String[] args) {

        Connection connection = null;

        try{
            Class.forName("org.postgresql.Driver");

            String url = "jdbc:postgresql://103.158.108.17:5432/1_CygnetGSPTenant_1";

            String userName = "CygGSPDBA";
            String password = "Admin#321";

            connection = DriverManager.getConnection(url,userName,password);

            System.out.println("Connected to the PostgreSQL database");
        }catch (ClassNotFoundException e){
            System.out.println("JDBC Driver Not Found!");
            e.printStackTrace();
        }catch (SQLException e){
            System.out.println("Connection failure!");
            e.printStackTrace();
        }finally {
            try {
                if (connection != null) {
                    connection.close();
                }
            }catch (SQLException e){
                System.out.println("Failed to close the Connection!");
                e.printStackTrace();
            }
        }
    }


    /*
    private static HikariDataSource dataSource;

    static {
        initializeDataSoucrce();
    }

    private static void initializeDataSoucrce(){
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:postgresql://103.158.108.17:5432/1_CygnetGSPTenant_1");
        config.setUsername("CygGSPDBA");
        config.setPassword("Admin#321");

        config.setMaximumPoolSize(10);

        dataSource = new HikariDataSource(config);
    }

    public static Connection getConnection() throws SQLException{
        return dataSource.getConnection();
    }

    public static void close(){
        if(dataSource != null){
            dataSource.close();
        }
    }
*/

}