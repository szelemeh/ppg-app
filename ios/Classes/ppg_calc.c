#include <stdio.h>
#include "ppg_calc.h"
#include <math.h>
#include <stdlib.h>

struct Point {
   int x;
   int y;
};  

int clamp(int lower, int higher, int val){
    if(val < lower)
        return 0;
    else if(val > higher)
        return 255;
    else
        return val;
}

int get_rotated_image_byte_index(int x, int y, int rotated_image_width){
    return rotated_image_width*(y+1)-(x+1);
}

uint32_t* convert_image(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2, int bytes_per_row, int bytes_per_pixel, int width, int height){
    int hexFF = 255;
    int x, y, uvIndex, index;
    int yp, up, vp;
    int r, g, b;
    int rt, gt, bt;

    uint32_t *image = malloc(sizeof(uint32_t) * (width * height));

    for(x = 0; x < width; x++){
        for(y = 0; y < height; y++){
            
            uvIndex = bytes_per_pixel * ((int) floor(x/2)) + bytes_per_row * ((int) floor(y/2));
            index = y*width+x;

            yp = plane0[index];
            up = plane1[uvIndex];
            vp = plane2[uvIndex];
          
            rt = round(yp + vp * 1436 / 1024 - 179);
            gt = round(yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91);
            bt = round(yp + up * 1814 / 1024 - 227);
            r = clamp(0, 255, rt);
            g = clamp(0, 255, gt);
            b = clamp(0, 255, bt);
          
            image[get_rotated_image_byte_index(y, x, height)] = (hexFF << 24) | (b << 16) | (g << 8) | r;
        }
    }
    return image;
}

uint8_t *get_threshholded_bitmask(uint32_t *image, int width, int height, int red_threshhold) {
    int x, y;
    uint8_t *bitmask = malloc(sizeof(uint8_t) * (width * height));
    for(x = 0; x < width; x++){
        for(y = 0; y < height; y++){
            uint32_t raw_pixel = image[y+x*width];
            uint8_t pixel[4];
            pixel[0] = raw_pixel >> 24;
            pixel[1] = raw_pixel >> 16;
            pixel[2] = raw_pixel >> 8;
            pixel[3] = raw_pixel;
            uint8_t red_value = pixel[3];
            if (red_value > red_threshhold) {
                bitmask[y+x*width] = 1;
            } else {
                bitmask[y+x*width] = 0;
            }
        }
    }
    // free(image);
    return bitmask;
}

struct Point *get_circle_center(uint8_t *bitmask, int width, int height) {
    int x, y;
    int x_avg = 0;
    int y_avg = 0;
    int count = 1;
    struct Point *center = malloc(sizeof(struct Point));
    for(x = 0; x < width; x++){
        for(y = 0; y < height; y++){
            if (bitmask[y+x*width]) {
                x_avg = x_avg + (x - x_avg)/count;
                y_avg = y_avg + (y - y_avg)/count;
                count += 1;
            }
        }
    }
    center->x = x_avg;
    center->y = y_avg;
    return center;
}

uint32_t calculate_ppg_value(uint8_t *bitmask, int width, int height) {
    struct Point *center = get_circle_center(bitmask, width, height);
    int x, y;
    // Going up
    int up_distance = 0;
    int up_found_border = 0;
    for(y = center->y; y < height; y++){
        if (bitmask[y+center->x*width]) {
            up_distance++;
        } else {
            up_found_border = 1;
            break;
        }
    }
    // Going down
    int down_distance = 0;
    int down_found_border = 0;
    for(y = center->y; y > 0; y--){
        if (bitmask[y+center->x*width]) {
            down_distance++;
        } else {
            down_found_border = 1;
            break;
        }
    }
    //Going left 
    int left_distance = 0;
    int left_found_border = 0;
    for(x = center->x; x > 0; x--){
        if (bitmask[y+center->x*width]) {
            left_distance++;
        } else {
            left_found_border = 1;
            break;
        }
    }
    //Going right
    int right_distance = 0;
    int right_found_border = 0;
    for(x = center->x; x < width; x++){
        if (bitmask[y+center->x*width]) {
            right_distance++;
        } else {
            right_found_border = 1;
            break;
        }
    }

    int sum = 0;
    int count = 0;
    if (up_found_border) {
        sum += up_distance;
        count += 1;
    }
    if (down_found_border) {
        sum += down_distance;
        count += 1;
    }
    if (left_found_border) {
        sum += left_distance;
        count += 1;
    }
    if (right_found_border) {
        sum += right_distance;
        count += 1;
    }

    // free(bitmask);
    int yes = 0;
    int no = 0;
    for(x = 0; x < width; x++){
        for(y = 0; y < height; y++){
            if (bitmask[y+x*width]) {
                yes++;
            }
            else {
                no++;
            }
        }
    }
    return center->y;
}

uint32_t calculate_ppg_value_from_image(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2, int bytes_per_row, int bytes_per_pixel, int width, int height, int red_threshhold) {
    uint32_t* image = convert_image(plane0, plane1, plane2, bytes_per_row, bytes_per_pixel, width, height);
    uint8_t *threshholded_bitmask = get_threshholded_bitmask(image, width, height, red_threshhold);
    uint32_t ppg_value = calculate_ppg_value(threshholded_bitmask, width, height);
    return ppg_value;
}

int main(){
    return 0;
}