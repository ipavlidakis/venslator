# Overview

Do you think localisations are difficult? Especially if you are an indie developer without a localisation team to support you or the funds for the available services? 
Do you also think that doing localisations should be easier? 

If yes, then venslator is the solution to your localisation problems. Venslator will remove the hussle of localising your iOS/macOS/iPadOS/tvOS apps or any other app that uses String files to store localisations strings.

Venslator, currently can translate your files using 2 APIs:
1. [Google Translate](https://cloud.google.com/translate) (free quota: 500k requests)
2. [NLP translation](https://rapidapi.com/gofitech/api/NLP%20Translation) (fee quota: 300 requests, limitation on concurrent requests to 2)

# How to use

## Installation
### From code
1. Clone or download the repo
2. Open terminal and cd into the repo's folder
3. The project is distributed as an SPM package. For that you will have to run 
```
swift package generate-xcodeproj && \
open venslator.xcodeproj
```
4. Run

### Build from code and install the binary
1. Clone or download the repo
2. Open terminal and cd into the repo's folder
3. the `install.sh` script will take care of building the project and moving it into your `/usr/local/bin/` path
```
./install.sh
```

### Download the binary
You can download the latest release's binary from the Releases page

## Usage
venslator requires the following options/arguements:
1. sourceLanguage: The language which your base file is using
2. targetLanguage(s): The language which you want to translate the base file's contents to(multiple languages supported, just use a comma seperated string)
3. api: Which API to use (Google Translate or NLPTranslation)
4. api-key: The key for the API you chose above
5. path: The path where your base file exists

The following are optional:
1. output-path: The output path for the newly translated file
2. protected-words:  Words that you don't want to translate(supported only on NLPTranslation API) 

## Examples
1. We want to localize using GoogleTranslate from English to Greek a file that exists in folder /Users/test/Desktop/localisations/en.lproj/Localizable.strings. The following command can be used
```
venslator \                                                 
en \
el \
/Users/test/Desktop/localisations/ \
--api gtranslate \
--api-key <YOUR-API-KEY>
```

2. We want to localize using NLPTranslation from English to Greek a file that exists in folder /Users/test/Desktop/localisations/en.lproj/Localizable.strings. The following command can be used
```
venslator \                                                 
en \
el \
/Users/test/Desktop/localisations/ \
--api nlptranslation \
--api-key <YOUR-API-KEY>
```

3. We want to localize using GoogleTranslate from Greek to Italian and Spanish a file that exists in folder /Users/test/Desktop/localisations/el.lproj/Localizable.strings. The following command can be used
```
venslator \                                                 
gr \
es,it \
/Users/test/Desktop/localisations/ \
--api gtranslate \
--api-key <YOUR-API-KEY>
```

## Notes
1. Speed depends mainly on the API you will choose
2. Before using the Google Translate API you will have to setup the gcloud cli on your computer following the instructions you can find [here](https://cloud.google.com/sdk/docs/install). Once you have done that you can you the following command to generate the API key for the API(as it's life duration it's small, you can regenerate it before running the venslator flow)
```
export GOOGLE_APPLICATION_CREDENTIALS=<PATH-TO-KEY-FILE> && \
gcloud auth application-default print-access-token 
```

## Next Steps
* Support more APIs(ping me for ideas)
* Introduce pre-run flows where checks - like gcloud being installed - will run
* Introduce validation checks on the newly localized files(usefuls for format strings)
* Support more file formats and folders structures
* Tests
* 🤔

## Contributions
Looking forward for your contributions

## Author
* [Twitter](https://twitter.com/3liaspav)
* [LinkedIn](https://www.linkedin.com/in/ipavlidakis/)
