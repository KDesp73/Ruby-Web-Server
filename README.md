# Ruby Web Server

## A simple functional server made with pure Ruby.

*It can host static websites*

![server index](https://user-images.githubusercontent.com/63654361/216193983-89083007-d1aa-44f4-b711-60ef24be02ec.png)

## Requirements

* Ruby 2.7.0 minimum

## How to use it

1. Clone this repository

    ```bash
    git clone https://github.com/KDesp73/Ruby-Web-Server
    ```
   
2. Run `bundle install` to install the necessary gems
    
3. Add your static site in the `docs/` folder

4. In selected directory run: 

    ```bash
    ruby ./run.rb
    ```
    The server is now running on localhost:2000

5. Change the configuration from the 'config.yml' file if necessary

## File Tree


```
.
├── LICENSE
├── README.md
└── Web_Server
    ├── config.yml
    ├── docs
    │   ├── food.js
    │   ├── index1.html
    │   ├── index_.html
    │   ├── script.js
    │   └── style.css
    ├── Gemfile
    ├── Gemfile.lock
    ├── run.rb
    └── src
        ├── request.rb
        ├── response.rb
        ├── server.rb
        ├── status_messages.yml
        └── utils
            ├── 404.html
            ├── favicon.ico
            └── index.html
```

## Licence

[MIT](https://github.com/KDesp73/Ruby-Web-Server/blob/main/LICENSE)
