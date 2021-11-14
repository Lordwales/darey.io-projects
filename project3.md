# MERN STACK IMPLEMENTATION ON AWS EC2


### Step 1 – Install Node.js, npm and create a new project

1. Run the following command to install Node.js:
```
sudo apt-get update
sudo apt-get install nodejs # run node -v afterwards to check version
```
2. Installing Nodejs above did not install NPM. So I ran the following command to install npm:
```
sudo apt-get install npm #run npm -v afterwards to check version
```
3. Now we can create a new project. Run the following command to create a new project:
```
mkdir Todo # create a new folder named Todo
npm init -y # initialises a new project
```
4. Run 'ls' to see the new folder contents. Package.json would have being create and it is the file that contains the project's dependencies.

### Step 2 – Install Express.js
1. Run the following command to install Express.js:
```
npm install express --save # installs express and saves it to package.json
```
2. create a new file called index.js in the Todo folder. This starts up ther express server.
```
touch index.js
```
3. Install dotenv to read environment variables from a .env file.
```
npm install dotenv --save # installs dotenv and saves it to package.json
```
4. Edit the index.js file to include the following code:  
```
const express = require('express');
require('dotenv').config();

const app = express();

const port = process.env.PORT || 5000; # process.env.PORT is the port number that the server is running on. This server will run on port 5000 if the environment variable PORT is not set.

app.use((req, res, next) => {
res.header("Access-Control-Allow-Origin", "\*");
res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
next();
});

app.use((req, res, next) => {
res.send('Welcome to Express');
});

app.listen(port, () => {
console.log(`Server running on port ${port}`)
});
```
5. Start the express server by running the following command:
```
node index.js
```
N.B. The server is going to run on port 5000.

6. We need to expose port 5000 on our imboud rules just like we did for the apache and nginx server.
The website should be visible at http://Ip-address:5000/

For the todo app to perform different tasks, we need to create api endpoints. This endpoints will use the  POST, GET, and DELETE methods.

1. Create routes folder and create an api.js file thats going to contain the api endpoints.
```
mkdir routes
touch api.js
```
2. Edit api.js with the following code block:
```
const express = require ('express');
const router = express.Router();

router.get('/todos', (req, res, next) => {

});

router.post('/todos', (req, res, next) => {

});

router.delete('/todos/:id', (req, res, next) => {

})

module.exports = router;
```
3. Install mongoose which helps us connect to mongodb.
```
npm install mongoose --save
```
4. Create models folder and create a todo.js file in it.
```
mkdir models
touch todo.js
```
5. Edit todo.js with the following code block:
```
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

//create schema for todo
const TodoSchema = new Schema({
action: {
type: String,
required: [true, 'The todo text field is required']
}
})

//create model for todo
const Todo = mongoose.model('todo', TodoSchema);

module.exports = Todo;
```
6.  Update the api.js file in routes folder to include the following code which will make use of model:
```
const express = require ('express');
const router = express.Router();
const Todo = require('../models/todo');

router.get('/todos', (req, res, next) => {

//this will return all the data, exposing only the id and action field to the client
Todo.find({}, 'action')
.then(data => res.json(data))
.catch(next)
});

router.post('/todos', (req, res, next) => {
if(req.body.action){
Todo.create(req.body)
.then(data => res.json(data))
.catch(next)
}else {
res.json({
error: "The input field is empty"
})
}
});

router.delete('/todos/:id', (req, res, next) => {
Todo.findOneAndDelete({"_id": req.params.id})
.then(data => res.json(data))
.catch(next)
})

module.exports = router;
```
7. Create a modngoDB database called todoDb on mongodb.com, create a user, allow connection anywhere and also create a collection called todo.

8. Create a .env file in the root directory of the project and add the following code:
```
DB = mongodb+srv://lordwales:<password>@cluster0.xmaqr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority
```
9. Edit the index.js file to include the following code:
```
const express = require('express');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');
const routes = require('./routes/api');
const path = require('path');
require('dotenv').config();

const app = express();

const port = process.env.PORT || 5000;

//connect to the database
mongoose.connect(process.env.DB, { useNewUrlParser: true, useUnifiedTopology: true })
.then(() => console.log(`Database connected successfully`))
.catch(err => console.log(err));

//since mongoose promise is depreciated, we overide it with node's promise
mongoose.Promise = global.Promise;

app.use((req, res, next) => {
res.header("Access-Control-Allow-Origin", "\*");
res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
next();
});

app.use(bodyParser.json());

app.use('/api', routes);

app.use((err, req, res, next) => {
console.log(err);
next();
});

app.listen(port, () => {
console.log(`Server running on port ${port}`)
});
```

10. Run the server by running the following command:
```
node index.js
```
11.The images bellow show the use of GET,POST and DELETE methods to quesry the database.



## FRONTEND
