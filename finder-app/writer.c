
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>

int writefile(const char *dir, const char *text){
	FILE *file_ptr = fopen(dir, "w");
	if(file_ptr == NULL){
		syslog(LOG_ERR, "Error on open file %s\n", dir);
		//printf("Error on open file %s\n", dir);
		return 1;
	}
	fprintf(file_ptr, "%s", text);
	
	if(ferror(file_ptr)){
		syslog(LOG_ERR, "Error - I/O operation\n");
		//printf("Error - I/O operation\n");
		fclose(file_ptr);
		return 1;
	}	
	fclose(file_ptr);
	return 0;
}

int main(int argc, char *argv[]){	
	openlog("writer.c", 0, LOG_USER);
	syslog(LOG_INFO, "Writer program start");
	if(argc == 3){
		syslog(LOG_DEBUG, "Writing %s to %s\n", argv[2], argv[1]);
		//printf("Writing %s to %s\n", argv[2], argv[1]);
		if(writefile(argv[1], argv[2]) == 1){
			return 1;
		};
	}else{
		//printf("Invalid insertion of directories. run.exe <FILENAME> <TEXT>\n");
		syslog(LOG_ERR, "Invalid insertion of directories. run.exe <FILENAME> <TEXT>\n");
		return 1;		
	}
	//printf("Done writing\n");
	syslog(LOG_INFO, "Done writing\n");
	closelog();
	return 0;
}
