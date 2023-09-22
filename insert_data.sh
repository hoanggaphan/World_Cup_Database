#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")

FILE="games.csv"

while IFS="," read year round winner opponent winner_goals opponent_goals
do
  if [[ $year != "year" ]]; then
    # Check if winner not in team
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    if [[ -z $WINNER_ID ]]; then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$winner') RETURNING team_id")
      WINNER_ID=$(echo $INSERT_WINNER_RESULT | awk '{print $1}')
      echo "Inserted into teams, $WINNER_ID: $winner"
    fi

    # Check if opponent not in team
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    if [[ -z $OPPONENT_ID ]]; then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$opponent') RETURNING team_id")
      OPPONENT_ID=$(echo $INSERT_OPPONENT_RESULT | awk '{print $1}')
      echo "Inserted into teams, $OPPONENT_ID: $opponent"
    fi

    # Insert game
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals) RETURNING game_id")
    GAME_ID=$(echo $INSERT_GAME_RESULT | awk '{print $1}')
    echo "Inserted into games, ID: $GAME_ID"
  fi
done < "$FILE"