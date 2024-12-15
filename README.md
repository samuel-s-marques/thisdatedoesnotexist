# thisdatedoesnotexist

Imagine a unique digital experience where real users can interact with AI-generated characters in a chat and matchmaking environment. This project, designed for my portfolio, combines cutting-edge technology to create a personalized and engaging interaction platform.

## Features

- **AI Characters:** The heart of the project lies in the AI characters. The skeleton of these characters, generated through [character-forge - npm](https://www.npmjs.com/package/character-forge), are procedurally created, each with distinct names, bios, hobbies/interests, relationship goals, etc.
- **AI Conversations:** Users engage with these AI characters as if they were real people. A sophisticated AI, like ChatGPT or other LLM model, powers these characters.
- **Smart Matching:** The [matchmaking algorithm](https://github.com/samuel-s-marques/thisdatedoesnotexist-profile-suggester/) identifies commonalities between users and AI characters, such as shared hobbies, political views, relationship goals, etc. When a strong match is detected, the AI character initiates the conversation, creating an immersive experience.
- **AI-Generated Photos:** To enhance realism, Stable Diffusion is employed to generate AI character photos. This adds an extra layer of authenticity to the characters' profiles.

## Technologies

- **Frontend:** The frontend is built using Flutter, with a focus on creating a seamless, engaging user experience.
- **Backend:** The backend is powered by Node.js, AdonisJS, MySQL, Redis, and Firebase (for authentication), providing a robust, scalable infrastructure for the project.
- **Error Monitoring:** Sentry is utilized for error monitoring and tracking within the application, ensuring quick identification and resolution of any issues that may arise in production environments.

## Screenshots and Videos
- [Chatting with a matched character - VIDEO](https://www.youtube.com/watch?v=bp5w28hu6S8)
- [Swiping characters - VIDEO](https://youtube.com/shorts/Via6c4NeUug)

## Installation

You need to have Flutter installed on your machine to run this project. Also, you need to clone, install and run [thisdatedoesnotexist-server](https://github.com/samuel-s-marques/thisdatedoesnotexist-server), as it is the backend.

To run the project locally, follow these steps:
1. Clone the repository.
```bash
git clone https://github.com/samuel-s-marques/thisdatedoesnotexist.git
```
2. Install the dependencies.
```bash
flutter pub get
```
3. Fill the `.env-example` with values and rename it to `.env`.
4. Run the project.
```bash
flutter run
```

## Use Cases:

While designed for personal and portfolio purposes, this concept has broader implications. It can serve as an experimental platform for studying user-AI interactions, testing the boundaries of AI's ability to replicate human connection. Furthermore, it can inspire future projects that harness the potential of AI to create personalized, meaningful experiences.

## Ethical Considerations:

While this project is for my portfolio and not intended for commercial use, ethics and user privacy remain a top priority. Clear communication with users about the nature of AI characters is crucial to maintain trust.

## Conclusion:

The "This Date Does Not Exist" isn't just a project that showcases the potential of AI in creating engaging and personalized interactions; it's a glimpse into the future of human-AI relationships. This fusion of technology and creativity underscores the boundless possibilities of AI applications and sets a new standard for responsible, user-centric AI experiences. It also serves as a testament to my technical skills, creative innovation and ethical considerations in the development of AI-driven applications.

## Support

If you encounter any bugs or issues, please report them in the [issue tracker](https://github.com/samuel-s-marques/thisdatedoesnotexist/issues).

## Related

Here are some related projects

[ThisBotDoesNotExist - procedurally generated characters powered by AI](https://github.com/samuel-s-marques/thisbotdoesnotexist)


## Authors

- **Samuel S Marques** - *Initial work* - [samuel-s-marques](https://github.com/samuel-s-marques)
