<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/login', function () {
    return view('login');
});

Route::post('/login', function (\Illuminate\Http\Request $request) {
    $email = $request->input('email');
    $password = $request->input('password');

    if ($email === 'test@example.com' && $password === 'password') {
        return redirect('/home');
    }

    return redirect('/login')->withErrors(['Invalid credentials']);
});