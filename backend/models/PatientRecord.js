const mongoose = require('mongoose');

const patientRecordSchema = new mongoose.Schema({
  referenceNumber: { type: String, unique: true },
  address: String,
  parentName: String,
  patientName: String,
  dob: Date,
  gender: String,
  height: String,
  weight: String,
  dateOfWeighing: Date,
  ageInMonths: Number,
  weightForAge: String,
  heightForAge: String,
  weightForHeight: String,
  nutritionStatus: String,
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'Users', required: true } // Correct data type
});

module.exports = mongoose.model('PatientRecord', patientRecordSchema);
