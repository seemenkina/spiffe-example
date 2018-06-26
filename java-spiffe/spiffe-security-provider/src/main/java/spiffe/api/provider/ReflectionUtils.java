package spiffe.api.provider;

public class ReflectionUtils {

    /**
     * Instantiate a class given the class name
     *
     * @param  className
     * @param <T>   instance type
     * @return instance
     */
    public static <T> T instantiate(String className) {
        return instantiate(loadClass(className));
    }

    @SuppressWarnings(value = "unchecked")
    private static <T> Class<T> loadClass(String name) {
        try {
            return (Class<T>) getContextClassLoader().loadClass(name);
        } catch (ClassNotFoundException e) {
            throw new IllegalArgumentException(e);
        }
    }

    private static <T> T instantiate(Class<T> clazz) {
        try {
            return clazz.getDeclaredConstructor().newInstance();
        } catch (ReflectiveOperationException e) {
            throw new IllegalArgumentException(e);
        }
    }

    private static ClassLoader getContextClassLoader() {
        return Thread.currentThread().getContextClassLoader();
    }
}
