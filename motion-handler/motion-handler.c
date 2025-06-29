#include <unistd.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <syslog.h>
#include <dirent.h>
#include <errno.h>
#include <string.h>
#include <poll.h>
#include <fcntl.h>
#include <getopt.h>
#include <sys/ioctl.h>
#include <linux/gpio.h>
#include <gpio-utils.h>

#define GPIO_DEV "gpiochip2"
#define GPIO_MOTION 13
#define GPIO_LED 21

int set_led(unsigned int gpio, bool on) {
  syslog(LOG_DEBUG, "Setting RGB on GPIO %d to %d...", gpio, on);

  gpiotools_set(GPIO_DEV, gpio, on);
}

bool get_motion_change(unsigned int gpio, int prev_value) {
  int value = prev_value;

  while (value == prev_value) {
    value = gpiotools_get(GPIO_DEV, gpio);
  }

  syslog(LOG_DEBUG, "Motion event: %d", value);

  return value == 1;
}

int main(int argc, char *argv[]) {
  openlog("WriterLog", 0, LOG_USER);

  syslog(LOG_DEBUG, "Starting...");

  if (argc > 1 && strcmp(argv[1], "-d") == 0) {
    syslog(LOG_DEBUG, "Starting as daemon...");
    if (daemon(1, 1) < 0) {
      perror("daemon");
	    exit(EXIT_FAILURE);
    }
  }

  syslog(LOG_DEBUG, "Starting motion detection...");

  bool prev_motion = 0;
  while (1) {
    bool motion = get_motion_change(GPIO_MOTION, prev_motion);
    prev_motion = motion;

    set_led(GPIO_LED, motion);
  }

  return EXIT_SUCCESS;
}
