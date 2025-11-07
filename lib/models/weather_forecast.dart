// lib/models/weather_forecast.dart (REVERTED TO HOURLY PLACEHOLDER)

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// --- DATA MODEL FOR HOURLY FORECAST (Corrected for Hourly View) ---
class HourlyItem {
  final String time; // The time (e.g., '4PM')
  final int temp;    // The hourly temperature
  final IconData icon;

  HourlyItem({required this.time, required this.temp, required this.icon});
}

// --- DATA MODEL FOR TODAY'S WEATHER ---
class TodayWeather {
  final String location;
  final int currentTemp;
  final String condition;
  final String warning;
  final IconData icon;
  final List<HourlyItem> forecastStrip; // This now holds the next few hours

  TodayWeather({
    required this.location,
    required this.currentTemp,
    required this.condition,
    required this.warning,
    required this.icon,
    required this.forecastStrip,
  });
}

// --- FINAL WEATHER SERVICE IMPLEMENTATION (Using Hourly Placeholder) ---
class WeatherService {
  // We use a fixed city name for the display
  Future<TodayWeather> fetchWeatherData() async {
    // Simulate network delay and return hardcoded HOURLY data.
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulating normal, cool weather for a calming card
    return TodayWeather(
      location: 'Kuala Lumpur',
      currentTemp: 27,
      condition: 'Partly Cloudy',
      warning: '', // No warning by default for a calming look
      icon: Icons.wb_cloudy_outlined,
      forecastStrip: [
        HourlyItem(time: '3 PM', temp: 28, icon: Icons.wb_sunny_outlined),
        HourlyItem(time: '4 PM', temp: 26, icon: Icons.wb_cloudy_outlined),
        HourlyItem(time: '5 PM', temp: 25, icon: Icons.cloud_outlined),
        HourlyItem(time: '6 PM', temp: 30, icon: Icons.nights_stay),
        HourlyItem(time: '7 PM', temp: 29, icon: Icons.nights_stay),
      ],
    );
  }
}