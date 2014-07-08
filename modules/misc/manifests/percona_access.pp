class misc::percona_access {
    user {
        'percona': 
            ensure => 'present',
            password => 'percona',
            managehome => 'true';
    }
    
    ssh_authorized_key {
        'consultant@sl1.percona.com':
            ensure => 'present',
            key => 'AAAAB3NzaC1yc2EAAAABIwAAAQEApP15RVFMg5kn9muPXWvPjNcITaTSs/GAPC8bw6HKtUGdP34J7Ytc2HMSDWKe22zZ8P2mz8E/FHgkE6mKZfiBryC8W0lzSittDlYLaaL77VvdB3JtNtyn0AwvBvjMFWvIK16Etcz5mXTSnfSoGxnW2HuN47BhAsPyUWoGm4+B+PUNLqjxfj5slYAah6SQmLzHyP5tC9h3E5yQ69bKBZXOZsyY0icu/q+AWzIe0d5A8PsgsIBl5iS65wMv/hVUR1Moz7tSzjpPm0KHl3exHGy0RMhAaZXU7+CmzM5rNpVQWrJmskfNm4dzGYJxqbSd12rMd+SdhsMapNxolYh0SKeX/w==',
            type => 'ssh-rsa',
            user => 'percona';
    }
    
    file {
        '/etc/sudoers.d/percona':
            ensure => 'present',
            content => 'percona ALL=(ALL) NOPASSWD: ALL';
    }
}