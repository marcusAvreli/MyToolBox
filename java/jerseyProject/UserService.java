package pictureGallery;

import javax.ws.rs.GET;
import javax.ws.rs.Produces;
import javax.ws.rs.Path;
import javax.ws.rs.core.MediaType;

@Path("users")
public class UserService {
	@Produces(MediaType.APPLICATION_JSON)
	@GET	
	public String getUsers() {
		 System.out.println("TEST users");
		return "hello world";
	}

}
