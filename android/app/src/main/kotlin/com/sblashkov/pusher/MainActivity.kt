package com.sblashkov.pusher

import android.util.Log
import androidx.annotation.NonNull
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.fitness.Fitness
import com.google.android.gms.fitness.FitnessActivities
import com.google.android.gms.fitness.FitnessOptions
import com.google.android.gms.fitness.data.DataPoint
import com.google.android.gms.fitness.data.DataSet
import com.google.android.gms.fitness.data.DataSource
import com.google.android.gms.fitness.data.DataType
import com.google.android.gms.fitness.data.Field
import com.google.android.gms.fitness.data.Session
import com.google.android.gms.fitness.data.WorkoutExercises
import com.google.android.gms.fitness.request.SessionInsertRequest
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.UUID
import java.util.concurrent.TimeUnit

const val GOOGLE_FIT_PERMISSIONS_REQUEST_CODE = 1111

class MainActivity : FlutterActivity() {
    private val _channel = "health_api_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, _channel)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                when (call.method) {
                    "getTodayPushUpsCount" -> {
                        result.success(5)
                    }

                    "writePushUpsData" -> {
                        writeWorkoutData(call, result)
                    }

                    "requestAuthorization" -> {
                        requestAuthorization(result)
                    }

                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    private fun writeWorkoutData(call: MethodCall, result: MethodChannel.Result) {
        if (context == null) {
            result.success(false)
            return
        }

        val sessionPushUps: Int = call.argument<Int>("sessionPushUps")!!
        if (sessionPushUps <= 0) {
            result.success(false)
            return
        }

        val endTimeMillis = System.currentTimeMillis()
        val startTimeMillis = endTimeMillis - (sessionPushUps * 3000) //about 3 sec per push up

        // Create the Activity Segment DataSource
        val activitySegmentDataSource = DataSource.Builder()
            .setAppPackageName(context!!.packageName)
            .setDataType(DataType.TYPE_WORKOUT_EXERCISE)
            .setStreamName("pusher - PushUp Activity")
            .setType(DataSource.TYPE_RAW)
            .build()
        // Create the Activity Segment
        val activityDataPoint = DataPoint.builder(activitySegmentDataSource)
            .setTimeInterval(startTimeMillis, endTimeMillis, TimeUnit.MILLISECONDS)
            .setField(Field.FIELD_EXERCISE, WorkoutExercises.PUSHUP)
            .setField(Field.FIELD_REPETITIONS, sessionPushUps)
            .setField(Field.FIELD_RESISTANCE_TYPE, Field.RESISTANCE_TYPE_BODY)
            .build()
        // Add DataPoint to DataSet
        val activitySegments = DataSet.builder(activitySegmentDataSource)
            .add(activityDataPoint)
            .build()

        val energyDataSource = DataSource.Builder()
            .setAppPackageName(context!!.packageName)
            .setDataType(DataType.TYPE_CALORIES_EXPENDED)
            .setStreamName("pusher - PushUp Calories")
            .setType(DataSource.TYPE_RAW)
            .build()
        val energyDataPoint = DataPoint.builder(energyDataSource)
            .setTimeInterval(startTimeMillis, endTimeMillis, TimeUnit.MILLISECONDS)
            // a generous estimate of one calorie per push up
            .setField(Field.FIELD_CALORIES, sessionPushUps.toFloat())
            .build()
        // Create a data set
        val energyDataSet = DataSet.builder(energyDataSource)
            .add(energyDataPoint)
            .build()

        // Finish session setup
        val session = Session.Builder()
            .setName("push ups on ${getDate(endTimeMillis)}")
            .setDescription("")
            .setIdentifier(UUID.randomUUID().toString())
            .setActivity(FitnessActivities.STRENGTH_TRAINING)
            .setStartTime(startTimeMillis, TimeUnit.MILLISECONDS)
            .setEndTime(endTimeMillis, TimeUnit.MILLISECONDS)
            .build()
        // Build a session and add the values provided
        val insertRequest = SessionInsertRequest.Builder()
            .setSession(session)
            .addDataSet(activitySegments)
            .addDataSet(energyDataSet)
            .build()

        val fitnessOptions = FitnessOptions.builder()
            .addDataType(DataType.TYPE_WORKOUT_EXERCISE, FitnessOptions.ACCESS_WRITE)
            .addDataType(DataType.TYPE_CALORIES_EXPENDED, FitnessOptions.ACCESS_WRITE)
            .build()

        try {
            val googleSignInAccount =
                GoogleSignIn.getAccountForExtension(context!!.applicationContext, fitnessOptions)
            Log.i("pusher", googleSignInAccount.getDisplayName()!!)
            Fitness.getSessionsClient(
                context!!.applicationContext,
                googleSignInAccount,
            )
                .insertSession(insertRequest)
                .addOnSuccessListener {
                    result.success(true)
                }
                .addOnFailureListener { exception ->
                    result.success(false)
                    Log.e(context!!.packageName, "There was an error adding the workout", exception)
                }
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun requestAuthorization(result: MethodChannel.Result) {
        if (context == null) {
            result.success(false)
            return
        }

        val fitnessOptions = FitnessOptions.builder()
            .addDataType(DataType.TYPE_WORKOUT_EXERCISE, FitnessOptions.ACCESS_WRITE)
            .addDataType(DataType.TYPE_CALORIES_EXPENDED, FitnessOptions.ACCESS_WRITE)
            .build()

        if (!GoogleSignIn.hasPermissions(
                GoogleSignIn.getLastSignedInAccount(this),
                fitnessOptions
            )
        ) {
            GoogleSignIn.requestPermissions(
                this,
                GOOGLE_FIT_PERMISSIONS_REQUEST_CODE,
                GoogleSignIn.getLastSignedInAccount(context!!),
                fitnessOptions
            )
        }
        result?.success(true)
    }

    private fun getDate(milliSeconds: Long): String {
        // Create a DateFormatter object for displaying date in specified format.
        val formatter = SimpleDateFormat(
            "dd/MM/yyyy hh:mm:ss",
            context!!.getResources().getConfiguration().getLocales().get(0)
        )

        // Create a calendar object that will convert the date and time value in milliseconds to date.
        val calendar: Calendar = Calendar.getInstance()
        calendar.timeInMillis = milliSeconds
        return formatter.format(calendar.time)
    }
}
