const express = require('express');
const router = express.Router();
const sql = require('mssql');

module.exports = function(pool) {
    router.post('/searchCarriage', (req, res) => {
        console.log(req);
        var TrainID = req.body.searchTerm;

        const request = new sql.Request(pool);
        request.input('ID', sql.NVarChar, TrainID);

        request.execute('SearchForCarriage', (err, result) => {
            if (err) {
                console.error(err);
                res.status(500).send('Internal Server Error');
            } else {
                var Carriage = result.recordset;
                res.json({ Carriage: Carriage });
            }
        });
    });

    router.post('/searchSeat', (req, res) => {
      console.log(req);
      var CarriageID = req.body.searchTerm;

      const request = new sql.Request(pool);
      request.input('CARRIAGEID', sql.NVarChar, CarriageID);

      request.execute('SearchForSeats', (err, result) => {
          if (err) {
              console.error(err);
              res.status(500).send('Internal Server Error');
          } else {
              var Seat = result.recordset;
              res.json({ Seat: Seat });
          }
      });
  });

  router.post('/addStation', (req, res) => {
    const { StationID, StationName, StationAddress } = req.body;

    const request = new sql.Request(pool);
    request.input('STATIONID', sql.NVarChar, StationID);
    request.input('STATIONNAME', sql.NVarChar, StationName);
    request.input('STATIONADDRESS', sql.NVarChar, StationAddress);


    request.execute('AddStation', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
            console.log(result.recordset);
            Message=result.recordset;
            res.json({ Message });
            
        }
    });
});

router.post('/addTrack', (req, res) => {
    const { Station1Id, Station2Id, Economy,Business,FirstClass } = req.body;

    const request = new sql.Request(pool);
    request.input('Station1Id', sql.NVarChar, Station1Id);
    request.input('Station2Id', sql.NVarChar, Station2Id);
    request.input('Economy', sql.Float, Economy);
    request.input('Business', sql.Float, Business);
    request.input('FirstClass', sql.Float, FirstClass);

    request.execute('InsertTrack', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
            console.log(result.recordset);
            Message=result.recordset;
            res.json({ Message });
            
        }
    });
});

router.post('/addSecurity', (req, res) => {
    const { CrewIdForSecurity,CrewNameForSecurity,AddressForSecurity,DateOfBirthForSecurity,StationId  } = req.body;


    // //for testing
    // console.log(CrewIdForSecurity);
    // console.log(CrewNameForSecurity);
    // console.log(AddressForSecurity);
    // console.log(DateOfBirthForSecurity);
    // console.log(StationId);    


    const request = new sql.Request(pool);
    request.input('CrewId', sql.NVarChar, CrewIdForSecurity);
    request.input('CrewName', sql.NVarChar, CrewNameForSecurity);
    request.input('Address', sql.NVarChar, AddressForSecurity);
    request.input('DateOfBirth', sql.Date, DateOfBirthForSecurity);
    request.input('StationId', sql.NVarChar, StationId);

    request.execute('AddSecurity', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
            console.log(result.recordset);
            Message=result.recordset;
            res.json({ Message });

            
        }
    });
});

router.post('/addPilot', (req, res) => {
    const { CrewIdForPilot,CrewNameForPilot,AddressForPilot,DateOfBirthForPilot,TrainId  } = req.body;

    const request = new sql.Request(pool);
    request.input('CrewId', sql.NVarChar, CrewIdForPilot);
    request.input('CrewName', sql.NVarChar, CrewNameForPilot);
    request.input('Address', sql.NVarChar, AddressForPilot);
    request.input('DateOfBirth', sql.Date, DateOfBirthForPilot);
    request.input('TrainId', sql.NVarChar, TrainId);

    request.execute('AddPilot', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
            console.log(result.recordset);
            Message=result.recordset;
            res.json({ Message });
            
        }
    });
});


router.post('/addRoute', (req, res) => {
    const { TrainId,TrackId,DepartureTime,ArrivalTime } = req.body;

    const request = new sql.Request(pool);

    request.input('ArrivalTime', sql.DateTime, ArrivalTime);
    request.input('DepartureTime', sql.DateTime, DepartureTime);
    request.input('TrackId', sql.NVarChar, TrackId);
    request.input('TrainId', sql.NVarChar, TrainId);

    request.execute('AddRoute', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
            console.log(result.recordset);
            Message=result.recordset;
            res.json({ Message });
            
        }
    });
});


router.post('/addCarriage', (req, res) => {
    const { TrainId, CarriageId,Type, NoOfSeats} = req.body;

    const request = new sql.Request(pool);

    request.input('NoOfSeats', sql.Int, NoOfSeats);
    request.input('Type', sql.Char, Type);
    request.input('CarriageId', sql.NVarChar, CarriageId);
    request.input('TrainId', sql.NVarChar, TrainId);

    request.execute('AddCarriage', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
            console.log(result.recordset);
            Message=result.recordset;
            res.json({ Message });
            
        }
    });
});


  router.post('/addTrain', (req, res) => {
    const { trainId, departureStation, ArrivalStation, upDownStatus } = req.body;

    const request = new sql.Request(pool);
    request.input('TRAINID', sql.NVarChar, trainId);
    request.input('DEPARTURESTATION', sql.NVarChar, departureStation);
    request.input('ARRIVALSTATION', sql.NVarChar, ArrivalStation);
    request.input('UPDOWNSTATUS', sql.NVarChar, upDownStatus);

    request.execute('AddTrain', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
            console.log(result.recordset);
            Message=result.recordset;
            res.json({ Message });
            
        }
    });
});



router.post('/editRoute', (req, res) => {
    const { TrainId,TrackId,DepartureTime,ArrivalTime } = req.body;

    const request = new sql.Request(pool);

    request.input('ArrivalTime', sql.DateTime, ArrivalTime);
    request.input('DepartureTime', sql.DateTime, DepartureTime);
    request.input('TrackId', sql.NVarChar, TrackId);
    request.input('TrainId', sql.NVarChar, TrainId);

    request.execute('EditRoute', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
            console.log(result.recordset);
            Message=result.recordset;
            res.json({ Message });
            
        }
    });
});


  router.post('/editTrain', (req, res) => {
    const { trainId, departureStation, ArrivalStation, upDownStatus } = req.body;

    const request = new sql.Request(pool);
    request.input('TRAINID', sql.NVarChar, trainId);
    request.input('DEPARTURESTATION', sql.NVarChar, departureStation);
    request.input('ARRIVALSTATION', sql.NVarChar, ArrivalStation);
    request.input('UPDOWNSTATUS', sql.NVarChar, upDownStatus);

    request.execute('EditTrain', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
            res.json({ message: 'Train updated successfully' });
            
        }
    });
});


router.post('/editFare', (req, res) => {
    const { TrackId,Economy,Business,FirstClass } = req.body;

    const request = new sql.Request(pool);
    request.input('TrackId', sql.NVarChar, TrackId);
    request.input('Economy', sql.Float, Economy);
    request.input('Business', sql.Float, Business);
    request.input('FirstClass', sql.Float, FirstClass);


    request.execute('EditFare', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
            console.log(result.recordset);
            Message=result.recordset;
            res.json({ Message });
            
        }
    });
});

router.post('/editSeat', (req, res) => {
    const { CarriageID, TrainID, SeatNo} = req.body;

    const request = new sql.Request(pool);
    request.input('CarriageID', sql.NVarChar, CarriageID);
    request.input('TrainID', sql.NVarChar, TrainID);
    request.input('SeatNo', sql.Int, SeatNo);
   
    request.execute('EditSeat', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
            Message=result.recordset;
            console.log(Message);
            res.json({ Message });
            
        }
    });
});


router.post('/editSecurity', (req, res) => {
    const { CrewId,CrewName,Address,StationId} = req.body;

    const request = new sql.Request(pool);
    request.input('CrewId', sql.NVarChar, CrewId);
    request.input('CrewName', sql.NVarChar, CrewName);
    request.input('Address', sql.NVarChar, Address);
    request.input('StationId', sql.NVarChar, StationId);
   
   
    request.execute('EditSecurity', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
            Message=result.recordset;
            console.log(Message);
            res.json({ Message });
            
        }
    });
});

router.post('/editPilot', (req, res) => {
    const { CrewId,CrewName,Address,TrainId} = req.body;

    const request = new sql.Request(pool);
    request.input('CrewId', sql.NVarChar, CrewId);
    request.input('CrewName', sql.NVarChar, CrewName);
    request.input('Address', sql.NVarChar, Address);
    request.input('TrainId', sql.NVarChar, TrainId);
   console.log(CrewId,CrewName,Address,TrainId);
   
    request.execute('EditPilot', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
            Message=result.recordset;
            console.log(Message);
            res.json({ Message });
            
        }
    });
});


router.delete('/deleteStation', (req, res) => {
    const { StationId } = req.query;

    const request = new sql.Request(pool);
    request.input('StationId', sql.NVarChar, StationId);
    request.execute('DeleteStation', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
           let Message=result.recordset;
            Message=Message[0];
            console.log(Message);
            if (Message.ResultMessage === 'Success') {
                console.log('Station deleted successfully');
                return res.sendStatus(200);
            } else {
                console.error('Failed to delete station:');
                return res.status(500).send('Failed to delete station');
            }
        }
    });
});

router.delete('/deleteTrack', (req, res) => {
    const { TrackId } = req.query;
    console.log(TrackId)
    const request = new sql.Request(pool);
    request.input('TrackId', sql.NVarChar, TrackId);
    request.execute('DeleteTrack', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
           let Message=result.recordset;
            Message=Message[0];
            console.log(Message);
            if (Message.ResultMessage === 'Success') {
                console.log('Track deleted successfully');
                return res.sendStatus(200);
            } else {
                console.error('Failed to delete Track:');
                return res.status(500).send('Failed to delete station');
            }
        }
    });
});


router.delete('/deleteRoute', (req, res) => {
    const { TrainId,TrackId } = req.query;
    console.log(TrackId)
    const request = new sql.Request(pool);
    request.input('TrackId', sql.NVarChar, TrackId);
    request.input('TrainId', sql.NVarChar, TrainId);
    request.execute('DeleteRoute', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
           let Message=result.recordset;
            Message=Message[0];
            console.log(Message);
            if (Message.ResultMessage === 'Success') {
                console.log('Track deleted successfully');
                return res.sendStatus(200);
            } else {
                console.error('Failed to delete Track:');
                return res.status(500).send('Failed to delete station');
            }
        }
    });
});


router.delete('/deleteCrew', (req, res) => {
    const { CrewId} = req.query;
    console.log(CrewId)
    const request = new sql.Request(pool);
    request.input('CrewId', sql.NVarChar, CrewId);

    request.execute('DeleteCrew', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
           let Message=result.recordset;
            Message=Message[0];
            console.log(Message);
            if (Message.ResultMessage === 'Success') {
                console.log('Crew deleted successfully');
                return res.sendStatus(200);
            } else {
                console.error('Failed to delete Track:');
                return res.status(500).send('Failed to delete station');
            }
        }
    });
});



router.delete('/deleteCarriage', (req, res) => {
    const { CarriageId} = req.query;
    console.log(CarriageId)
    const request = new sql.Request(pool);
    request.input('CarriageId', sql.NVarChar, CarriageId);

    request.execute('DeleteCarriage', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
           let Message=result.recordset;
            Message=Message[0];
            console.log(Message);
            if (Message.ResultMessage === 'Success') {
                console.log('Carriage deleted successfully');
                return res.sendStatus(200);
            } else {
                console.error('Failed to delete Carriage:');
                return res.status(500).send('Failed to delete station');
            }
        }
    });
});

router.delete('/deleteTrain', (req, res) => {
    const { TrainId} = req.query;
    console.log(TrainId)
    const request = new sql.Request(pool);
    request.input('TrainId', sql.NVarChar, TrainId);

    request.execute('DeleteTrain', (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Internal Server Error');
        } else {
           let Message=result.recordset;
            Message=Message[0];
            console.log(Message);
            if (Message.ResultMessage === 'Success') {
                console.log('Train deleted successfully');
                return res.sendStatus(200);
            } else {
                console.error('Failed to delete Train:');
                return res.status(500).send('Failed to delete station');
            }
        }
    });
});






    return router;
};
