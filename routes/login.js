const express = require('express');
const router = express.Router();
const sql = require('mssql');
const fs = require('fs');

// Route handler for user signup
module.exports = (pool) => {
  router.post('/', async (req, res) => {
    const { cnic, password } = req.body;

    try {
      // Call the stored procedure to authenticate the user
      const result = await pool.request()
        .input('CNIC', sql.NVarChar(255), cnic)
        .input('Password', sql.NVarChar(255), password)
        .execute('AuthenticateUser');

      if (result.returnValue === 0) {
        // User account found, retrieve user details



        
       const userDetails = {
          userId: result.recordset[0].ID,
          username: result.recordset[0].UserName,
          cnic: cnic
        }; //we have to fetch username and id from database and no need to do this for cnic because we already have it because user entered it in the form

        // Clear the JSON file before writing new data
        fs.writeFileSync('loggedInCredentials.json', JSON.stringify({}));  //basically we are writing empty obj to clear already present data
        // Write user details to the JSON file
        fs.writeFileSync('loggedInCredentials.json', JSON.stringify(userDetails, null, 2));
        //render the login form with a success message
        res.render('login', { successMessage: 'User logged in successfully!' });
      } 
      else {
        // User account not found, render the login form with an error message
        res.render('login', { errorMessage: 'User account not found! Please input valid credentials.' });
      }
    } catch (error) {
		console.error('Error authenticating user:', error);  //for displaying on terminal ( the actual error )
		// Send the error message to the client side for display
		res.render('login', { errorMessage: 'User account not found! Please input valid credendials.' });
    }
  });

  return router;
};
