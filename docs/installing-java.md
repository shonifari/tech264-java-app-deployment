# Installing Java, JDK and Maven

- [Installing Java, JDK and Maven](#installing-java-jdk-and-maven)
  - [Windows 11](#windows-11)

## Windows 11

1. Download the Java installer from [Java official website](https://www.java.com/en/download/)
2. Download the Maven binafies from [Apache Maven official website](https://maven.apache.org/download.cgi)
3. Either add the `maven/bin/mvn` executable to PATH environment variable or to your `.basrhc` file.
4. Run `mvn -v` to output the version of maven.

5. **Install a JDK:**
   - Ensure a compatible JDK (e.g., JDK 17) is installed on your system.
   - You can download the JDK from [Oracle](https://www.oracle.com/java/technologies/javase-downloads.html), or other sources.

6. **Set the `JAVA_HOME` Environment Variable:**
   - Locate your JDK installation path (e.g., `C:\Program Files\Java\jdk-17` on Windows or `/usr/lib/jvm/java-17-openjdk` on Linux).
   - Set `JAVA_HOME` to point to the JDK installation:
     - **Windows**:
       1. Open System Properties → Advanced → Environment Variables.
       2. Add a new system variable:
          - Name: `JAVA_HOME`
          - Value: JDK installation path.
       3. Add `%JAVA_HOME%\bin` to the `PATH` variable.
     - **Linux/Mac**:
       Add the following lines to your shell configuration file (`~/.bashrc`, `~/.zshrc`, or similar):

       ```bash
       export JAVA_HOME=/path/to/jdk
       export PATH=$JAVA_HOME/bin:$PATH
       ```

       Run `source ~/.bashrc` (or equivalent) to apply the changes.

7. **Verify the Configuration:**
   - Run the following commands to ensure the JDK is correctly set up:

     ```bash
     java -version
     javac -version
     ```

   - Both commands should display the JDK version.

8. **Rebuild the Project:**
   - Clean the Maven build:

     ```bash
     mvn clean
     ```

   - Rebuild the project:

     ```bash
     mvn compile
     ```

If the issue persists, let me know the exact environment (e.g., OS, Java version, etc.), and we can troubleshoot further!
