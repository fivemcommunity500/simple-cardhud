window.addEventListener('message', (event) => {
    const d = event.data;

    if (d.action === "updateSeatbelt") {
        const beltIcon = document.getElementById('belt-icon');
        beltIcon.className = d.belt ? "status-svg active-white" : "status-svg active-red";
        return;
    }

    if (d.action === "updateCarHUD") {
        const hud = document.getElementById('car-hud');
        if (d.show) {
            hud.style.display = "block";
            document.getElementById('speed').innerText = d.speed;
            document.getElementById('gear').innerText = d.gear;
            document.getElementById('street-label').innerText = d.street;

            // Traducciones dinámicas
            document.getElementById('lbl-fuel').innerText = d.txtFuel;
            document.getElementById('lbl-eng').innerText = d.txtEngine;
            document.getElementById('lbl-gear').innerText = d.txtGear;

            const rpmFill = document.getElementById('rpm-fill');
            rpmFill.style.strokeDashoffset = 240 - (d.rpm * 240);
            
            document.getElementById('fuel-bar').style.height = d.fuel + "%";
            let enginePct = (d.engine / 1000) * 100;
            document.getElementById('eng-bar').style.height = enginePct + "%";
            
            document.getElementById('light-icon').className = d.lights ? "status-svg active-white" : "status-svg";
        } else {
            hud.style.display = "none";
        }
    }
});