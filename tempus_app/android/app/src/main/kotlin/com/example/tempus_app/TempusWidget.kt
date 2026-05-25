package com.dev.tempusapp

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.dev.tempusapp.R

class TempusWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (id in appWidgetIds) {
            updateWidget(context, appWidgetManager, id)
        }
    }
}

private fun updateWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val prefs = context.getSharedPreferences("HomeWidgetPlugin", Context.MODE_PRIVATE)
    val dailyMinutes = prefs.getInt("daily_minutes", 0)
    val goalMinutes = prefs.getInt("goal_minutes", 0)

    val timeText = formatMinutes(dailyMinutes)
    val progress = if (goalMinutes > 0)
        ((dailyMinutes.toFloat() / goalMinutes) * 100).toInt().coerceIn(0, 100)
    else 0

    val views = RemoteViews(context.packageName, R.layout.tempus_widget_layout)
    views.setTextViewText(R.id.widget_time_value, timeText)
    views.setProgressBar(R.id.widget_progress, 100, progress, false)

    // Tap opens the app
    val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
    if (intent != null) {
        val pendingIntent = PendingIntent.getActivity(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_time_value, pendingIntent)
    }

    appWidgetManager.updateAppWidget(appWidgetId, views)
}

private fun formatMinutes(minutes: Int): String {
    if (minutes == 0) return "0 min"
    if (minutes < 60) return "$minutes min"
    val h = minutes / 60
    val m = minutes % 60
    return if (m > 0) "${h}h ${m}min" else "${h}h"
}
