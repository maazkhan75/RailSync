//importing necessary modules
const createError = require('http-errors');
const bodyParser = require('body-parser');
const express = require('express');
const session = require('express-session');
const path = require('path');
const cookieParser = require('cookie-parser');
const logger = require('morgan');
const sql=require('mssql');
const fs = require('fs');
const nodemailer = require('nodemailer');

// Create an instance of the Express application
const app = express();
const port=4000;   //our port

// Configure session middleware
app.use(session({
  secret: '053eb1bb21545cd881a8e15b6fab7e58be948187fddd5babd64dd2c5e77614b7',
  resave: false,
  saveUninitialized: false
}));



function isAuthenticated(req, res, next)
{
  if(req.session.userDetails && req.session.userDetails.cnic){
    //user is authenticated proceed with the request
    next();
  }
  else 
  {
     //redirect an error page
    console.log('Forbidden: access denied because of authentication bypass!');
    res.redirect('/errorOfSession');
  }
}


const sendEmail = async (name, email, subject, message) => {
  // Create a transporter object using the default SMTP transport
  let transporter = nodemailer.createTransport({
    service: 'gmail', // e.g., 'gmail', 'hotmail', etc.
    auth: {
      user: 'your_email@example.com', // Your email address
      pass: 'your_email_password' // Your email password or app password if using Gmail
    }
  });

  // Email content
  let mailOptions = {
    from: 'your_email@example.com',
    to: 'maazkhan75555@gmail.com', // Your email address where you want to receive messages
    subject: subject,
    text: `Name: ${name}\nEmail: ${email}\n\nMessage: ${message}`
  };

  // Send email
  await transporter.sendMail(mailOptions);
};

// app.post('/contact', (req, res) => {
//   //console.log('testing123');
//   const { name, email, subject, message } = req.body;

//   console.log(name);

//   // Call the sendEmail function to send the email
//   sendEmail(name, email, subject, message)
//     .then(() => {
//       console.log('Email sent successfully');
//       res.render('./USER/dashboard.ejs'); // Render a success page or redirect to another page
//     })
//     .catch((error) => {
//       console.error('Error sending email:', error);
//       res.render('./USER/dashboard.ejs'); // Render an error page
//     });
// });



app.post('/contact', (req, res) => {
  try {
    // Log the entire request body
    console.log('Request Body:', req.body);

    // Extract form data
    const { name, email, subject, message } = req.body;

    // Log form data for debugging
    console.log('Name:', name);
    console.log('Email:', email);
    console.log('Subject:', subject);
    console.log('Message:', message);

    // Call the sendEmail function to send the email
    sendEmail(name, email, subject, message)
      .then(() => {
        console.log('Email sent successfully');
        res.render('./USER/dashboard.ejs'); // Render a success page or redirect to another page
      })
      .catch((error) => {
        console.error('Error sending email:', error);
        res.render('./USER/dashboard.ejs'); // Render an error page
      });
  } catch (error) {
    console.error('Error processing request:', error);
    res.status(500).send('An error occurred while processing the request');
  }
});


// Body parser middleware
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

//importing routers
const signupRouter = require('./routes/signup')
const loginRouter = require('./routes/login')
const indexRouter = require('./routes/index');
const usersRouter = require('./routes/users');
const SearchTrainRouter = require('./routes/SearchTrain');
const SearchCarriage = require('./routes/TD');
const sessionRouter = require('./routes/testSession');
const profileUpdateRouter = require('./routes/profileUpdate');
const passwordChangeRouter = require('./routes/passwordChange');


const { Console } = require('console');
const { render } = require('ejs');

//configuring a connection pool for MSSQL using the mssql module and connecting to the database
const sqlConfig = {
  user:'afaqkhaliq_SampleDB',
  password:'afaq123',
  database:'afaqkhaliq_SampleDB',
  server: 'sql.bsite.net\\MSSQL2016',
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 3000000
  } , options: {
    encrypt: true, // for azure
    trustServerCertificate: true // change to true for local dev / self-signed certs
  }
}
const pool = new sql.ConnectionPool(sqlConfig);
pool.connect((err)=>{
  if (err) {
    console.error('Database connection failed:', err);
  } else {
    console.log('Database connection successful!');
  }
})


// view engine setup
app.set('views', path.join(__dirname, 'views'),path.join(__dirname, 'views/ADMIN'),path.join(__dirname, 'views/ADMIN/partials'),path.join(__dirname, 'views/USER'),path.join(__dirname, 'views/USER/partials'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));  //set up your Express server to serve static files from public directory..( thats why we have used absolute paths everywhere then )


// Define a route to render an ejs/html page
app.get('/home',(req,res)=>{
res.render('home.ejs');
});

app.get('/decisionPg',(req,res)=>{
res.render('decision.ejs');
});

app.get('/signupForm',(req,res)=>{
res.render('signup.ejs');
});

app.get('/loginForm',(req,res)=>{
  res.render('login.ejs');
});

app.get('/errorOfSession',(req,res)=>{
  res.render('errorSession.ejs');
});


app.get('/SearchTrainform', (req, res) => {
  pool.query('SELECT StationName FROM Station')
      .then(result => {
          const StationNames = result.recordset;
          var isSubmitted=false;
          res.render("form.ejs", { StationNames ,isSubmitted});
      })
      .catch(err => {
          console.error(err);
          res.status(500).send('Internal Server Error');
      });
});

app.get('/admin', (req, res) => {
  pool.query('SELECT * FROM Train')
      .then(result => {
          const Trains = result.recordset;
          res.render("admin.ejs", { Trains });
      })
      .catch(err => {
          console.error(err);
          res.status(500).send('Internal Server Error');
      });
});

app.get('/trainData', (req, res) => {
  pool.query('SELECT * FROM Train')
      .then(result => {
          const Trains = result.recordset;
          res.render("./ADMIN/trainData.ejs", { Trains });
      })
      .catch(err => {
          console.error(err);
          res.status(500).send('Internal Server Error');
      });
});

app.get('/ticketsData', (req, res) => {
  pool.query('SELECT * FROM Ticket ')
      .then(result => {
          const Tickets = result.recordset;
          res.render("./ADMIN/ticketsData.ejs", { Tickets });
      })
      .catch(err => {
          console.error(err);
          res.status(500).send('Internal Server Error');
      });
});

app.get('/faq', (req, res) => {  
  try
  {
  res.render("./USER/faq.ejs");
  }
  catch(error)
  {
    console.error(err);
    res.status(500).send('Internal Server Error');
  };
});

app.get('/logout',(req,res)=>{

  req.session.destroy(err => {

    if(err){
      console.error('error destroying session: ',err);
    }
    else
    {
       res.redirect('/home');
    }
  });

});




app.get('/showTicketsOfUser', isAuthenticated, async (req, res) => {
  const cnic = req.session.userDetails.cnic;
	  try {
		// Call the stored procedure to fetch booked tickets
		const result = await pool.request()
		  .input('CNIC', sql.NVarChar(255), cnic)
		  .execute('ShowBookedTickets');
	
		if (result.returnValue === 0) 
    {
		  console.log('Tickets found!');
		  const Tickets = result.recordset; 
      console.log(Tickets)
      const ticketsUpcoming = [];
      const ticketsPrevious = [];
      const currentTime = new Date();
      // console.log(currentTime);
      Tickets.forEach((ticket) => {

        const deptTime=new Date(ticket.deptTime);
        if(deptTime >= currentTime)
        {
          ticketsUpcoming.push(ticket);
        }
        else
        {
          ticketsPrevious.push(ticket);
        }
      });

      // Assuming this is how your ticket data is structured
		  res.render('./USER/ticketsOfUser.ejs',{ticketsPrevious,ticketsUpcoming}); 
      // Send ticket data as JSON response
		} 
    else
    {
		  throw new Error('Failed to retrieve tickets');
		} 
	  } 
    catch (error)
    {
		console.error('Error retrieving tickets:', error);
		res.status(500).send('Failed to retrieve tickets');
	  }
});

app.get('/ds', (req, res) => {
  res.render('./ADMIN/dashboard.ejs');
});

app.get('/contact', (req, res) => {
  res.render('./USER/contact.ejs');
});

app.get('/userDash', isAuthenticated, (req,res)=>{
  const userData = req.session.userDetails;
  res.render('./USER/dashboard.ejs',{userData});
  })

app.get('/stationData', (req, res) => {
  const requestStation = new sql.Request(pool);
  const requestTrack = new sql.Request(pool);

  // Execute both queries asynchronously
  Promise.all([
    requestStation.query('SELECT * FROM Station'),
    requestTrack.query('SELECT * FROM Tracks join Fare on Tracks.TrackId=Fare.TrackId')
  ])
  .then(results => {
    const Station = results[0].recordset;
    const Track = results[1].recordset;
    res.render('./ADMIN/stationData.ejs', { Station:Station, Track:Track });
  })
  .catch(err => {
    console.error(err);
    res.status(500).send('Internal Server Error');
  });
});

app.get('/routeData', (req, res) => {
     
  pool.query('SELECT * FROM Route as R join Tracks as T on R.TrackId=T.TrackId')
  .then(result => {
 
      const Route =result.recordset;
      console.log(Route);
      res.render("./ADMIN/routesData.ejs", { Route });
  })
  .catch(err => {
      console.error(err);
      res.status(500).send('Internal Server Error');
  });
});



app.get('/staffdata', (req, res) => {
  
  Promise.all([
     
      pool.query('SELECT * FROM Pilot as p join Crew as c on c.CrewId=p.CrewId'),
      pool.query('SELECT * FROM Security as s join Crew as c on c.CrewId=s.CrewId')
    ])
  .then(([PilotResult,SecurityResult]) => {
   
      const Pilot = PilotResult.recordset;
      const Security=SecurityResult.recordset;
      res.render("./ADMIN/staffData.ejs", { Pilot,Security });
  })
  .catch(err => {
      console.error(err);
      res.status(500).send('Internal Server Error');
  });
});


app.get('/addCarriage', (req, res) => {
     
  pool.query('SELECT * FROM Train ')
  .then(result => {
      const Train =result.recordset;

      res.render("./ADMIN/CarriageForm.ejs", { Train });
  })
  .catch(err => {
      console.error(err);
      res.status(500).send('Internal Server Error');
  });
});



app.get('/addRoute', (req, res) => {
  
  Promise.all([
     
      pool.query('SELECT * FROM Train'),
      pool.query('SELECT * FROM Tracks')
    ])
  .then(([TrainResult,TrackResult]) => {
   
      const Train = TrainResult.recordset;
      const Track=TrackResult.recordset;
      res.render("./ADMIN/RouteForm.ejs", { Train,Track });
  })
  .catch(err => {
      console.error(err);
      res.status(500).send('Internal Server Error');
  });
});

app.get('/form', (req, res) => {
  res.render('./ADMIN/form.ejs');
});

app.get('/staffData', (req, res) => {
  res.render('./ADMIN/staffData.ejs');
});

app.get('/addTrain', (req, res) => {
  pool.query('SELECT * FROM Station')
      .then(result => {
          const Station = result.recordset;

          res.render('./ADMIN/trainForm.ejs', {  Station: Station });

      })
      .catch(err => {
          console.error(err);
          res.status(500).send('Internal Server Error');
      });
  
});

app.get('/addStation', (req, res) => {
  res.render('./ADMIN/stationForm.ejs');
});

app.get('/addTrack', (req, res) => {
  pool.query('SELECT * FROM Station')
  .then(result => {
      const Station = result.recordset;
      res.render('./ADMIN/TrackForm.ejs', {Station: Station });

  })
  .catch(err => {
      console.error(err);
      res.status(500).send('Internal Server Error');
  });
});

app.get('/addSecurity', (req, res) => {
  pool.query('SELECT * FROM Station')
  .then(result => {
      const Station = result.recordset;
      res.render('./ADMIN/SecurityForm.ejs', {Station: Station });

  })
  .catch(err => {
      console.error(err);
      res.status(500).send('Internal Server Error');
  });
});

app.get('/addPilot', (req, res) => {
  pool.query('SELECT * FROM Train')
  .then(result => {
      const Train = result.recordset;
      res.render('./ADMIN/PilotForm.ejs', {Train: Train });

  })
  .catch(err => {
      console.error(err);
      res.status(500).send('Internal Server Error');
  });
});

app.get('/addCarriage', (req, res) => {
  res.render('./ADMIN/CarriageForm.ejs');
});


app.get('/editTrain', (req, res) => {
  const TrainId = req.query.TrainID;
  pool.query('SELECT * FROM Station')
      .then(result => {
          const Station = result.recordset;
          res.render('./ADMIN/editTrain.ejs', { TrainId: TrainId, Station: Station });

      })
      .catch(err => {
          console.error(err);
          res.status(500).send('Internal Server Error');
      });
  
});

app.get('/editRoute', (req, res) => {
  const TrainID = req.query.TrainID;
  const TrackID=req.query.TrackID;
  res.render('./ADMIN/editRoute.ejs', {TrainID,TrackID });
});

app.get('/editTrack', (req, res) => {

  const TrackID=req.query.TrackID;
  const Economy=req.query.Economy;
  const BusinessClass=req.query.BusinessClass;
  const FirstClass=req.query.FirstClass;
  res.render('./ADMIN/editTrack.ejs', {TrackID,Economy,BusinessClass,FirstClass });
});

app.get('/profile', isAuthenticated, async(req,res)=>{
  const cnic=req.session.userDetails.cnic;
  try{
    const result = await pool.request()
    .input('CNIC', sql.NVarChar(255), cnic)
    .execute('GetUserCredentials');

    if (result.returnValue === 0 && result.recordset.length>0) {

      const userCredentials = {
         userId: result.recordset[0].Id,
         username: result.recordset[0].UserName,
         password: result.recordset[0].Password,
         cnic: result.recordset[0].CNIC,
         phone: result.recordset[0].PhoneNo
       }

       //console.log(userCredentials.password);  for testing
        res.render('./USER/profile.ejs',{userCredentials});
    }
    else
    {
      res.status(404).send('user not found');
    }
    }
    catch(err){
      console.error(err);
      res.status(500).send('Internal Server Error');
    }
})


app.post('/bookTicketNonStop', (req, res) => {  
  console.log(req.body);
  const userName = req.session.userDetails.username;
  console.log(userName);
  const InputTrackId=req.body.TrackID;
  var inputClassType=req.body.selectedClass;
  if(req.body.selectedClass==="Economy") inputClassType="E";
  else if(req.body.selectedClass==="Bussiness") inputClassType="B";
  else if(req.body.selectedClass==="First Class") inputClassType="F";

  const request= new sql.Request(pool);
  request.input('TrainId',sql.NVarChar(30),req.body.selectedTrainID);
  request.input('TrackId',sql.NVarChar(30),req.body.TrackID);
  request.input('Class',sql.NVarChar(30),inputClassType);
  var TicketAvailInfo="";
  request.execute('BookTicket',(err,result)=>{
    if(err){
      console.log(err);
      res.status(500).send('Internal Server Error');
    }
    else{
        TicketAvailInfo=result.recordset[0];
        console.log(TicketAvailInfo);
        if(TicketAvailInfo.length!= undefined){
          const TicketInfoReq= new sql.Request(pool);
        TicketInfoReq.input('FoundCarriage',sql.NVarChar(30),TicketAvailInfo.CarriageId);
        TicketInfoReq.input('TrainId',sql.NVarChar(30),req.body.selectedTrainID);
        TicketInfoReq.input('FoundSeat',sql.Int,TicketAvailInfo.SeatNo);
        TicketInfoReq.input('TrackId',sql.NVarChar(30),InputTrackId);
        console.log(InputTrackId);
        TicketInfoReq.execute('GetTicketInfo',(err,result2)=>{

        if(err){
          console.error(err);
          res.status(500).send('Internel Server Error');
        }
        else{
          console.log("seat details are: ");
          console.log(result2);
        }

        var TicketInfo=result2.recordset;
        res.render('Ticket',{TicketInfo,inputClassType,userName});
      });
    } 
    else{
        res.send("No Avaiailable Seat Found");
    }
  }
  })
});


// Use the routes
app.use('/', indexRouter);
app.use('/users', usersRouter);
app.use('/signup', signupRouter(pool));   // Pass pool object to signupRouter
app.use('/login', loginRouter(pool));     // Pass pool object to loginRouter
app.use('/SearchTrain', SearchTrainRouter(pool));
app.use('/TD',SearchCarriage(pool));
app.use('/', sessionRouter);    //for testing session
app.use('/profileUpdate',profileUpdateRouter(pool))
app.use('/passwordChange',passwordChangeRouter(pool))


// Catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// Error handler for 404 errors
app.use(function(err, req, res, next) {
  if (err.status === 404) {
    res.status(404).render('error404');
  } else {
    next(err);
  }
});

// Error handler for other errors (500 and any other status codes)
app.use(function(err, req, res, next) {
  // Set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // Render the error page
  res.status(err.status || 500);
  res.render('error500');
});


// Export the app and pool objects
module.exports = { app, pool };

// Start the server and listen on port 4000   //write localhost:4000/home to start the website
app.listen(port,(error)=>{
  if(error)
      console.log("Error listening");
  else{
    console.log(`Server is listening on port - ${port}`);
  }
})