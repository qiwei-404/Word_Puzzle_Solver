/***********************************************************************
* File       : <2dstrfind.c>
*
* Author     : <M.R. Siavash Katebzadeh>
*
* Description:
*
* Date       : 08/10/19
*
***********************************************************************/
// ==========================================================================
// 2D String Finder
// ==========================================================================
// Finds the matching words from dictionary in the 2D grid

// Inf2C-CS Coursework 1. Task 3-5
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2019

#include <stdio.h>

// maximum size of each dimension
#define MAX_DIM_SIZE 32
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 1000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 10

int read_char() { return getchar(); }
int read_int()
{
  int i;
  scanf("%i", &i);
  return i;
}
void read_string(char* s, int size) { fgets(s, size, stdin); }
void print_char(int c)     { putchar(c); }
void print_int(int i)      { printf("%i", i); }
void print_string(char* s) { printf("%s", s); }
void output(char *string)  { print_string(string); }

// dictionary file name
const char dictionary_file_name[] = "../data/dictionary.txt";
// grid file name
const char grid_file_name[] = "../data/2dgrid.txt";
// content of grid file
char grid[(MAX_DIM_SIZE + 1 /* for \n */ ) * MAX_DIM_SIZE + 1 /* for \0 */ ];
// content of dictionary file 
char dictionary[MAX_DICTIONARY_WORDS * (MAX_WORD_SIZE + 1 /* for \n */ ) + 1 /* for \0 */ ];
///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////Put your global variables/functions here///////////////////////


// starting index of each word in the dictionary
int dictionary_idx[MAX_DICTIONARY_WORDS];
// number of words in the dictionary
int dict_num_words = 0;
// create a grid matrix
char grid_m[MAX_DIM_SIZE + 1 /* max number of rows */][MAX_DIM_SIZE + 1 /* max number of columns */];




// function to print found word
void print_word(char *word)
{
  while(*word != '\n' && *word != '\0') {
    print_char(*word);
    word++;
  }
}

// function to see if the string contains the (\n terminated) word
int contain(char *string, char *word)
{
  while (1) {
    if (*string != *word){
      return (*word == '\n');
    }

    string++;
    word++;
  }

  return 0;
}

// this functions finds all matches in the grid
void strfind()
{
  int idx = 0;
  char *word;
  int contains = 0;
  int x_coord = 0;
  int y_coord = 0;
  // find horizontal matches
  while (grid_m[x_coord][y_coord] != '\0') {
	  while (grid_m[x_coord][y_coord] != '\n') {
	    for(idx = 0; idx < dict_num_words; idx ++) {
	      word = dictionary + dictionary_idx[idx]; 
	      if (contain(&grid_m[x_coord][y_coord] , word)) {
	        contains = 1;
		      print_int(x_coord);
	        print_char(',');
		      print_int(y_coord);
	        print_char(' ');
	        print_char('H');
	        print_char(' ');
		      print_word(word);
		      print_char('\n');
	      }
      }
	    y_coord++;
	  }  
	  x_coord++;
	  y_coord = 0;
  }
  int total_rows = x_coord;  
  x_coord = 0;
  
  // find vertical matches
  while (grid_m[x_coord][y_coord] != '\n') {
	  char col_word[total_rows + 1 /* for \0 */];
	  while (x_coord < total_rows) {
	    col_word[x_coord] = grid_m[x_coord][y_coord];
	    x_coord++;										  
	  }
	  col_word[x_coord] = '\0';
	  x_coord = 0;
	  int start_idx = 0;
	  while (col_word[start_idx] != '\0') {
	    for(idx = 0; idx < dict_num_words; idx ++) {
	      word = dictionary + dictionary_idx[idx]; 
	      if (contain(&col_word[start_idx], word)) {
	        contains = 1;
		      print_int(start_idx);
		      print_char(',');
		      print_int(y_coord);
		      print_char(' ');
		      print_char('V');
		      print_char(' ');
		      print_word(word);
		      print_char('\n');
	      }
	    }
	    start_idx++;
	  }
	  y_coord++;
  }
  
  //find diagonal matches
  int total_cols = y_coord;
  int dg_length;
  if (total_rows > total_cols) {
	  dg_length = total_cols;
  }
  else {
	  dg_length = total_rows;
  }
  int col_start_idx = 0;
  int row_start_idx = 0;
  while (grid_m[row_start_idx][col_start_idx] != '\n' && grid_m[row_start_idx][col_start_idx] != '\0') {
	  while (grid_m[row_start_idx][col_start_idx] != '\n' && grid_m[row_start_idx][col_start_idx] != '\0') {
	    char dg_word[dg_length + 1 /* for \0 */];
	    int dg_idx = 0;
	    x_coord = row_start_idx;
	    y_coord = col_start_idx;
	    while (grid_m[x_coord][y_coord] != '\n' && grid_m[x_coord][y_coord] != '\0') {
	      if (dg_idx < dg_length) {
		      dg_word[dg_idx] = grid_m[x_coord][y_coord];
		      dg_idx++;
	      }
		    else {
		      dg_word[dg_idx] = '\0';
		    }
	      x_coord++;
		    y_coord++;
	    }  
	    for(idx = 0; idx < dict_num_words; idx ++) {
	      word = dictionary + dictionary_idx[idx]; 
		    if (contain(&dg_word[0], word)) {
		      contains = 1;
		      print_int(row_start_idx);
		      print_char(',');
		      print_int(col_start_idx);
		      print_char(' ');
		      print_char('D');
		      print_char(' ');
		      print_word(word);
		      print_char('\n');
		    }
	    }
	    col_start_idx++;  
	  }
	  row_start_idx++;
	  col_start_idx = 0;
  }
  if (!contains) {
    print_string("-1\n");
  }  
}



//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main (void)
{

  /////////////Reading dictionary and grid files//////////////
  ///////////////Please DO NOT touch this part/////////////////
  int c_input;
  int idx = 0;


  // open grid file
  FILE *grid_file = fopen(grid_file_name, "r");
  // open dictionary file
  FILE *dictionary_file = fopen(dictionary_file_name, "r");

  // if opening the grid file failed
  if(grid_file == NULL){
    print_string("Error in opening grid file.\n");
    return -1;
  }

  // if opening the dictionary file failed
  if(dictionary_file == NULL){
    print_string("Error in opening dictionary file.\n");
    return -1;
  }
  // reading the grid file
  do {
    c_input = fgetc(grid_file);
    // indicates the the of file
    if(feof(grid_file)) {
      grid[idx] = '\0';
      break;
    }
    grid[idx] = c_input;
    idx += 1;

  } while (1);

  // closing the grid file
  fclose(grid_file);
  idx = 0;
   
  // reading the dictionary file
  do {
    c_input = fgetc(dictionary_file);
    // indicates the end of file
    if(feof(dictionary_file)) {
      dictionary[idx] = '\0';
      break;
    }
    dictionary[idx] = c_input;
    idx += 1;
  } while (1);


  // closing the dictionary file
  fclose(dictionary_file);
  //////////////////////////End of reading////////////////////////
  ///////////////You can add your code here!//////////////////////

  
  // index for starting letters of each word in the dictionary
  int dict_idx = 0;
  // temporary index storage for starting letters of each word in the dictionary
  int start_idx = 0;
  
  // storing indices of starting letters of each word into the array dictionary_idx
  idx = 0;
  do {
    c_input = dictionary[idx];
    if(c_input == '\0') {
      break;
    }
    if(c_input == '\n') {
      dictionary_idx[dict_idx ++] = start_idx;
      start_idx = idx + 1;
    }
    idx += 1;
  } while (1);

  dict_num_words = dict_idx;
  
  // convert grid to a matrix
  int row_num = 0;
  int col_num = 0;
  int total_cols = 0;
  idx = 0;
  while (grid[idx] != '\0') {
    if (grid[idx] != '\n') {
      grid_m[row_num][col_num] = grid[idx];
      col_num++;
	    idx++;
	  }
    else {
      grid_m[row_num][col_num] = grid[idx];
      total_cols = col_num;
      idx++;
      col_num = 0;
      row_num++;	
    }  
  }
  int c = 0;
  for (c=0; c <= total_cols; c++) {
	  grid_m[row_num][c] = '\0';  
  }
  
  strfind();
  
  return 0;
}
