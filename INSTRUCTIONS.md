# Tupi's Software Engineer Test

Thanks for applying to a Software Engineer Position on Tupi!

This test's goal is to evaluate some soft skills and hard skills that we value on our culture.

### Soft Skills
1. Pro-activity
2. Communication
3. Self Taught
4. Critical Tought
5. Self Management

### Technical Skills
1. Debugging
2. Git versioning
3. Planning a solution
4. Architecture
5. Automated Tests (and Test Driven Development)
6. Generative AI (ChatGPT, Bing, Gemini, Codeium...)

We know it's hard to evaluate this on a technical test, but we will try our best to use our interviews to help on that too!

After this test we may schedule a quick call to talk about questions regarding your solution to further understand those skills above.

## Rules
1. We value fast solutions and due dates. So don't take more than **4 hours** to do your test. 
2. Take some time before the **4 hours** to read this instructions, ask any questions about it on the issues here https://github.com/tupinamba-energia/software-engineer-test/issues (send through email/message to anyone from Tupi that are following your hiring process), research everything on internet and plan what you want to do.
3. To start this test you can clone this repository locally (please don't fork it).
4. To start counting the 4 hour period you NEED to commit a blank `README.md` file on the root, right on the beginning of your test.
5. Keep commiting during your test. We recommend you to do it every 25~30min. Avoid having one big commit on the end of the test, otherwise you may be disqualified.
6. We don't expect you to finish the project, it's the process that matters. So by the end of the 4 hours just stop, zip your local repository, and send it to who is following your hirirng process.
7. Don't use all 4 hours to code. Separate 30 min ~ 1 hour from the end of the 4 hour period to write your `README.md` file with your thoughts, what you expected to do, planning, how to run etc... Remember, **communication** is one of the skills evaluated. You can use anything to explain what are your thoughts, a video (you can use [Loom](https://www.loom.com/) to record your screen and your camera), an audio, a presentation, and/or of course, writing on the README, to explain what you planned to do. Anything that makes you feel comfortable.
8. You can/should use any AI to help you, but please comment which one you used on your `README.md`
9. You need to use **Typescript** to develop the solution.
10. You can choose any Test Framework to write your tests, but please make a `npm run test` command so we can run it. (If you don't know how to write automated tests you can skip it, but this will be considered negative on your evaluation)

Given this rules lets go to the test!

## Project - HR Company showing github repositories from candidates

Consider this is an HR Company that tries to select Software Developers to hiring process from our clients.
Our Product Team wants to list the public repositories of a github user in our app. So we as Tech team need to automatize this based on a candidate github username.
Tho achieve this we will write an API using `express` (or any other Typescript framework of your choice) that have 2 endpoints:
1. curl -X POST "http://localhost:3000/gh_user_repos" -d '{"username":"<github_username>"}'
2. curl -X GET "http://localhost:3000/gh_user_repos/<github_username>"

### POST /gh_user_repos

The first endpoint receives a <github_username> and uses it to get github repositories from it and save it on a DATABASE.
- For a DATABASE you can use a simple JSON file that the server reads and writes everything. Want to use another DB solution? Such as SQLITE, MySQL/MariaDB, MongoDB... Just remember to comment it on the `README.md` how to setup your project
- The API to get github repositories is `GET https://api.github.com/users/<github_username>/repo`, and don't require authentication.
- This endpoint need to answer `HTTP status 201` with `{"payload": { "github_username": "<github_username>"}, "message": "request created" }` when success
- This endpoint need to answer `HTTP status 500` with `{"payload": { "github_username": "<github_username>"}, "message": "<error_message>" }` when some server processing failed
- This endpoint need to answer `HTTP status 422` with `{"payload": { "github_username": "<github_username>"}, "message": "<error_message>" }` when the request misses some data, such as <github_username>
- Other responses may be required if you can think in other scenarios feel free to add them, we will test other scenarios to see how the endpoint behaves

\* The url and HTTP Method, and HTTP responses can be something different if you like, just document it on the README

#### BONUS points for more experienced developers
- You can consider scalability and the github api failing, so how would you make this request answer fast without blocking the http worker? 

### GET /gh_user_repos/<github_username>

The second endpoint returns the github repositories and the stars each one have in this JSON response.
```json
{
  "repos": [
    {
      "name": "<string:repo_name>",
      "stargazers_count": <int:stargazers_count>,
      "html_url": "<string:html_url>"
    },
    //... rest of the repos of the github_username stored on the DB
  ]
}
```
- This endpoint need to answer `HTTP status 200` with the payload above when success
- This endpoint need to answer `HTTP status 422` with `{"payload": { "github_username": "<github_username>"}, "message": "<error_message>" }` when the request misses some data, such as <github_username>
- This endpoint need to answer `HTTP status 500` with `{"payload": { "github_username": "<github_username>"}, "message": "<error_message>" }` when some server processing failed
- Other responses may be required if you can think in other scenarios feel free to add them, we probably will test other scenarios to see how the endpoint behaves

#### BONUS points for more experienced developers
- Considering scalability and that the previous fetch of repositories may not be ready yet, how this endpoint should respond?

