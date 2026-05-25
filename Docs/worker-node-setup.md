1. Generate SSH key pair.

   <img width="397" height="247" alt="image" src="https://github.com/user-attachments/assets/397945c7-b9f0-4fb1-a193-dc283749199e" />

2. Copy the worker node public key from `/root/.ssh/id_rsa.pub` to the master node `/root/.ssh/authorized_keys`.

   <img width="395" height="58" alt="image" src="https://github.com/user-attachments/assets/243a90f3-f7c7-4d8a-909c-a652dabf2def" />

3. Create Jenkins working directory under the home directory.

   <img width="203" height="88" alt="image" src="https://github.com/user-attachments/assets/e13acd88-3b48-4da5-a0a7-2b3bfb015eeb" />

4. Run the command apt update and apt install openjdk-17-jre-headless

   <img width="783" height="686" alt="image" src="https://github.com/user-attachments/assets/0627bb64-369c-4d0e-8f7e-352ba63f4082" />

5. Log in to Jenkins and run the following command on the workernode.

   <img width="856" height="167" alt="image" src="https://github.com/user-attachments/assets/b579b53e-daf8-47f0-b3a7-df1a63910449" />

6. Ensure the worker node is successfully connected to the agent. Once connected, the pipeline can be executed.

   <img width="793" height="387" alt="image" src="https://github.com/user-attachments/assets/1b8ccdc8-94f9-4103-90ac-0c2196948476" />



    


