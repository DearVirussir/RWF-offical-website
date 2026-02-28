const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://jrczxzsaxrlkmhdrnwrh.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpyY3p4enNheHJsa21oZHJud3JoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIyNTczMzQsImV4cCI6MjA4NzgzMzMzNH0.FzBQRRk5XVr3ie-Xf5m9INjr--ndUvraJZY-_aoIZLc';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testConnection() {
    console.log('Testing Supabase Connection...');

    // Test contact_messages insert
    const { data, error } = await supabase
        .from('contact_messages')
        .insert([
            { name: 'System Test', email: 'test@system.local', subject: 'Connection Test', message: 'Hello from the terminal test script' }
        ])
        .select();

    if (error) {
        console.error('Error connecting to Supabase:', error.message);
        if (error.code === '42P01') {
            console.error('TABLE DOES NOT EXIST. Please ensure you have run the supabase_schema.sql in your Supabase SQL Editor.');
        }
    } else {
        console.log('Successfully connected and inserted test message!', data);

        // Clean up test message
        if (data && data[0] && data[0].id) {
            await supabase.from('contact_messages').delete().eq('id', data[0].id);
            console.log('Cleaned up test message.');
        }
    }
}

testConnection();
