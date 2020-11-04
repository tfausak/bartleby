# Bartleby

This tool is meant to help edit the output of AWS Transcribe without losing any
information. That means you can import a transcript file, make some edits, and
get back a transcript file. The most common edits I want to support are editing
a single word, removing a single word, combining adjacent words, and splitting
one word into two. I want to do all that while retaining timing and speaker
information, which existing tools don't do.

## To do

- [ ] Display speaker information somehow.
- [ ] Allow editing a single word at a time.
- [x] Allow exporting the transcript as JSON.
