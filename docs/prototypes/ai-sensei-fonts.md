# AI Sensei prototype fonts

The reference `Mockup - Alt Lesson Page & Flashcards.pdf` uses M PLUS 1p for its interface and Kids UP Reading for the flashcard phrase.

`app/assets/fonts/ai-teacher/` contains M PLUS 1p Regular, Medium, and Bold, downloaded from the [Google Fonts source repository](https://github.com/google/fonts/tree/main/ofl/mplus1p). Its SIL Open Font License is included as `OFL.txt`. The prototype serves these files locally.

`KidsUPReading-hello.ttf` is the embedded font subset extracted from the supplied PDF, with its table alignment and checksums repaired for browser compatibility. It contains outlines only for `Hello!`; the remaining letters are blank in that subset. Only the Hello flashcard uses it. The other sample phrases use M PLUS 1p until the complete Kids UP Reading font is supplied. Do not apply this subset to other phrases.

`app/assets/ai-teacher/remote/speed.svg` preserves the speed selector artwork from page 11 of the same PDF, matching the other extracted remote icons.
