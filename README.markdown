# Bartleby

This tool is meant to help edit the output of AWS Transcribe without losing any
information. That means you can import a transcript file, make some edits, and
get back a transcript file. The most common edits I want to support are editing
a single word, removing a single word, combining adjacent words, and splitting
one word into two. I want to do all that while retaining timing and speaker
information, which existing tools don't do.

This tool does not keep track of the split between pronunciation and
punctuation. If that is important to you, you'll have to use something else.

## To do

- [x] Allow exporting the transcript as JSON.
- [x] Display speaker information somehow.
- [x] Create maximal speaker label segments.
- [x] Avoid defaulting times to zero (and other values). (Instead drop those items?)
- [x] Allow editing a single word at a time.
- [x] Allow changing speaker names.
- [x] Delete a word.
- [x] Split a word.
- [ ] Combine two words.
- [ ] Improve performance of speaker identification.
- [ ] Handle more speakers.
- [ ] Come up with better internal representation of job and chunks.
