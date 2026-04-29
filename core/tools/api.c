#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

#define CONTROL_PIPE "/run/initctl"

void print_usage() {
    printf("Professional OS API\n");
    printf("Usage: pro-api <command> <service_name>\n");
    printf("Commands: start, stop, restart, status\n");
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        print_usage();
        return 1;
    }

    char *command = argv[1];
    char *service = argv[2];
    char buffer[256];

    // تنسيق الرسالة التي ستُرسل للمدير
    snprintf(buffer, sizeof(buffer), "%s:%s", command, service);

    // فتح الأنبوب المخصص للتحكم
    int fd = open(CONTROL_PIPE, O_WRONLY);
    if (fd == -1) {
        perror("Error: API cannot connect to Manager (Pipe missing)");
        return 1;
    }

    write(fd, buffer, strlen(buffer));
    close(fd);

    printf("[API] Command '%s' sent for service: %s\n", command, service);
    return 0;
}

