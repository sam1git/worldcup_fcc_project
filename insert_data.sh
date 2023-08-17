#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE games, teams")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    #check winner in teams, add if not present and add to games
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ -z $WINNER_TEAM_ID ]]
    then
      echo "Adding to teams: $WINNER"
      echo -e "$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")\n"
      WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    #check opponent in teams, add if not present and add to games
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $OPPONENT_TEAM_ID ]]
    then
      echo "Adding to teams: $OPPONENT"
      echo -e "$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")\n"
      OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    #Add year, round, winner_id, opponent_id, winner_goals, opponent_goals to teams
    echo "Adding to games: $YEAR $ROUND $WINNER v. $OPPONENT"
    echo -e "$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_TEAM_ID,$OPPONENT_TEAM_ID,$WINNER_GOALS,$OPPONENT_GOALS)")\n"
  fi
done