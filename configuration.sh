# Configuration example
# Doesn't need root, it's a joke.

if [ "$ENV_TYPE" = 'live' ]; then
    DB="db"
    USER="root"
    PASSWORD="12345safe"
    HOST="localhost"
    PORT="3306"
elif [ "$ENV_TYPE" = 'test' ]; then
    DB="db"
    USER="root"
    PASSWORD="12345"
    HOST="localhost"
    PORT="3306"
elif [ "$ENV_TYPE" = 'dev' ]; then
    DB="db"
    USER="root"
    PASSWORD="12345"
    HOST="localhost"
    PORT="3306"
fi

