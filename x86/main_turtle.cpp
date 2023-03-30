#include <stdio.h>
#include <fstream>
#include <iostream>

extern "C" int turtle(unsigned char *dest_bitmap, unsigned char *commands, unsigned int commands_size);
using std::fstream;	using std::ios;
using std::cout;	using std::endl;

int main(void)
{
	fstream file_bmp;
	file_bmp.open("output.bmp", ios::in | ios::binary);
	if (file_bmp.is_open())
	{
		unsigned char bytes_bmp[90123];
		int counter_bmp = 0;
		while (not file_bmp.eof())
		{
			bytes_bmp[counter_bmp] = file_bmp.get();
			counter_bmp +=1;
		}
		file_bmp.close();
		fstream file_bin;
		file_bin.open("input.bin", ios::in | ios::binary);
		if (file_bin.is_open())
		{
		    unsigned char bytes_bin[61];
		    int commands_bin = 0;
		    while (not file_bin.eof())
		    {
				bytes_bin[commands_bin] = file_bin.get();
				commands_bin +=1;
		    }
			commands_bin -=1;
			
			cout << "Bytes in binary file: " << commands_bin << endl;
			
			int result = turtle(bytes_bmp, bytes_bin, commands_bin);
			
			FILE* output = fopen("output.bmp", "wb");
			fwrite(bytes_bmp, 1, 90122, output);
			fclose(output);
			std::cout << "Saved to 'output.bmp' "  << std::endl;
			std::cout << result  << std::endl;
			file_bin.close();
			return 0;
		}
		else
		{
			cout << ".bin file error" << endl;
			return 1;
		}
	}
	else
	{
		cout << ".bmp file error" << endl;
		return 1;
	}
}
