#define GNU_SOURCE
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>
#include <signal.h>
#include <syslog.h>
#include <arpa/inet.h>

#define MAX_SIZE 256
#define PORT 9000
#define FILEPATH "./aesdsocketdata"
//#define FILE "/var/tmp/aesdsocketdata"

int sockfd;
int new_socket;
bool sign_ack = false;
socklen_t addr_size;
struct sockaddr_in servaddr;
struct sockaddr_in client_addr;
FILE *fp;
struct sigaction sig;
int daemon_flag;

void exiting_program(){
	close(sockfd);
	close(new_socket);
	fclose(fp);

}

void handlerSIG(int signal){
	syslog(LOG_INFO, "SIG signal callback");
	if(signal == SIGINT || signal == SIGTERM){
		sign_ack = true;
		syslog(LOG_INFO, "Closed connection from %s\n", inet_ntoa(client_addr.sin_addr));
		syslog(LOG_INFO, "Exiting program\n");
		printf("Exiting program\n");
	}
}

int main(int argc, char **argv){	
	char buff[MAX_SIZE];
	char data[MAX_SIZE];
	int len;
	char * line = NULL;
	ssize_t reader;

	//arguments validation - daemon
	if(argc == 2){
		if(strcmp(argv[1], "-d") == 0){
			daemon_flag = 1;
			printf("daemon flag on->%d\n", daemon_flag);
		}
	}else{
		daemon_flag = 0;
	}
	
	//start syslog
	openlog (NULL, 0, LOG_USER);
	memset(&sig, 0, sizeof(sig));
	sig.sa_handler = handlerSIG;
	
	//start socket
	if((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0){
		printf("Error on creating a socket!\n");
		syslog(LOG_ERR, "Error on creating a socket!\n");
		exiting_program();
	}
	printf("Socket created\n");
	
	//server configs
	servaddr.sin_family = AF_INET;
	servaddr.sin_port = htons(PORT);
	servaddr.sin_addr.s_addr = INADDR_ANY;
	
	//bindings configs
	if(bind(sockfd, (struct sockaddr_in *)&servaddr, sizeof(servaddr)) < 0){
		printf("Error on binding socket\n");
		syslog(LOG_ERR, "Error on binding socket\n");
		exiting_program();
	}
	printf("Socket bind\n");
		
	
	//listen socket
	if(listen(sockfd, 1) != 0){
		printf("Error on listenning socket\n");
		syslog(LOG_ERR, "Error on listenning socket\n");
		exiting_program();
	}
	printf("Socket listen\n");
		
	do{
		//file open
		fp = fopen(FILEPATH, "a");
		if(fp == NULL){
			printf("Error on openning file: %s\n", FILEPATH);
			syslog(LOG_ERR, "Error on openning file\n");
			exiting_program();
		}
		
		//accept connection
		addr_size = sizeof(client_addr);
		new_socket = accept(sockfd, (struct sockaddr_in *)&client_addr, &addr_size);
		if(new_socket < 0){
			printf("Error  on accepting socket\n");
			syslog(LOG_ERR, "Error  on accepting socket");
			exiting_program();
		}
		printf("Accepted connection from %s\n", inet_ntoa(client_addr.sin_addr));
		syslog(LOG_INFO, "Accepted connection from %s\n", inet_ntoa(client_addr.sin_addr));
		
		memset(buff, 0, MAX_SIZE); //clear buffer to received data
		
		//received from connection
		if(recv(new_socket, buff, MAX_SIZE, 0) == -1){
			printf("Error on receiving socket packet\n"); 
			syslog(LOG_ERR, "Error on receiving socket packet\n");
			exiting_program();
		}
		printf("Socket:%d-> data received:%s\n", new_socket, buff);
		
		
		fprintf(fp, "%s", buff);	
		fclose(fp);	
		
		memset(buff, 0, MAX_SIZE); //clear buffer to received data
		
		fp = fopen(FILEPATH, "r");
		if(fp == NULL){
			printf("Error on openning file: %s\n", FILEPATH);
			syslog(LOG_ERR, "Error on openning file\n");
			exiting_program();
		}
		
	 	while ((reader = getline(&line, &len, fp)) != -1) {
		    strcat(data, line);
		    
	    }
		fclose(fp);
		
		if(send(new_socket, data, strlen(data), 0) < 0){
			printf("Error on seding response to cliente\n");
			syslog(LOG_ERR, "Error on seding response to cliente\n");
			exiting_program();
		}
		printf("Socket response sent\n");
	
	}while(1);	
	
	memset(data, 0, MAX_SIZE);
	exiting_program();
	return 0;
}


/*
-
-port 9000 -> OK
-logs message "Accepted connection from 'ipaddress'" - NOK
-received data and appends to file /var/tmp/aesdsocketdata, separated by new line - OK
-returns the full content /var/tmp/aesdsocketdata to the client as soon as the received data packet completes - NOK
-logs close connection from 'ipaddress' - NOK
-restart accepting connections from the new clients forever in a loopp ulti sigint or sigterm is received
-exits when SIGS happen and deleting the /var/tmp/aesdsocketdata.
- accept argument '-d' which runs the application as a daemon. In this case shoud fork() after ensuring it can be bind in to port 9000


*/
