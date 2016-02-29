# Test-Vectors-Compression-Analysis
Small MacOS X application for generating and compressing test vectors for testing digital devices


**The application features:**
- Generation of test vectors with normally distributed random bits;
- Exhaustive search for finding the most compressed possible input;
- Repeates generation/compression of test vectors specified number of times to get statistically relevant results;
- Intensive computation runs in background with displaying progress.


**Idea:**

If you have some test vectors that you need to enter into digital device via serial test port (like JTAG) you can find such sequence, that end of previous test vector will be the same as start of next test vector, which means you don't need to enter it again, effectively decreasing time for testing this device. 
This application uses exhaustive search to find the most compressed input and show what compression was achieved.
