# Project-Management-API
Project Management API is a tool designed to be used in conjunction with Project-Management-Frontend. Project Management will help manage multiple projects, and the associated stories. It allows users to create projects, status them as a whole. As well as, create smaller stories for each project, and status them out as well.  



## Installation
Step One: Fork and Clone Repository. After checking out the repo run the following commands.

```zsh
bundle install
```

```zsh
rake db:migrate
```

```zsh
rake db:seed
```


Step Two: You will need to install the frontend [Project-Management-Frontend](https://github.com/pbsmith82/project-management-frontend). Once you have setup the backend, you will be able use Project Management. 

Simply make sure your backend is available on the localserver and open Index.html from the frontend.

## Usage
Users will be able to create projects, status them as a whole. As well as, create smaller stories for each project, and status them out as well.

## Deployment to Heroku

This application is configured for deployment to Heroku. Follow these steps:

1. **Install Heroku CLI** (if not already installed):
   ```zsh
   brew tap heroku/brew && brew install heroku
   ```

2. **Login to Heroku**:
   ```zsh
   heroku login
   ```

3. **Create a new Heroku app**:
   ```zsh
   heroku create your-app-name
   ```

4. **Add PostgreSQL addon** (if not automatically added):
   ```zsh
   heroku addons:create heroku-postgresql:mini
   ```

5. **Set the Rails master key** (get this from `config/master.key`):
   ```zsh
   heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)
   ```

6. **Deploy to Heroku**:
   ```zsh
   git push heroku master
   ```

7. **Run database migrations**:
   ```zsh
   heroku run rails db:migrate
   ```

8. **Seed the database** (optional):
   ```zsh
   heroku run rails db:seed
   ```

9. **Open your app**:
   ```zsh
   heroku open
   ```

**Note:** The `release` command in the Procfile will automatically run migrations on each deploy, but you may need to run them manually the first time.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
Project Management is available as open source under the terms of the [MIT License](https://github.com/pbsmith82/project-management-api/blob/master/LICENSE).