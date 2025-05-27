package pictureGallery;



import javax.ws.rs.core.Application;


import java.util.HashSet;
import java.util.Set;




public class JerseyWrapper  extends Application {
	private Set<Class<?>> classes = new HashSet<Class<?>>(8);
	private Set<Object> singletons = new HashSet<Object>(8);
	 public JerseyWrapper() {
		 System.out.println("TEST JerseyWrapper");
		 singletons.add(new UserService());
	 }
	 @Override
	    public Set<Class<?>> getClasses() {
	        //Register resources
	        classes.add(UserService.class);
	        
	        return classes;
	    }
	 @Override
		public Set<Object> getSingletons() {
			return singletons;
		}
}

