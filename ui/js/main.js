$(function(){
    let reports = {}
    let activeReport
    let user = ''
    let category = $(".game-bug span").data("category");
    let reportId = 1

    $.post(`https://${GetParentResourceName()}/uiLoaded`, function(name){
        user = name;
    })

    window.addEventListener("message", function(event) {
        let data = event.data;
        
        switch(data.action){
            case 'openReportMenu':
                openReportMenu()
            break;

            case 'openAdminMenu':
                $.post(`https://${GetParentResourceName()}/getReports`, function(Reports){
                    let text = '';
                
                    for (let i = 0; i < Reports.length; i++){
                        reports = Reports
                        let report = Reports[i]

                        text += `
                        <div class="report" data-reportid="${report.reportId}">
                            <div class="id">#${report.reportId}</div>
                            <div class="player">${report.reporter.name}</div>
                            <div class="asister">${report.concluded ? report.concludedby : "None"}</div>
                            <div class="category-a">${report.category}</div>
                            <div class="action">
                                <div class="btn view">View</div>
                            </div>
                        </div>
                        `      
                    }
                    
                    openAdminMenu()
                    $(".reports-wrapper .reports").html(text)
                        
                    $(".action .view").click(function(){
                        for (let i = 0; i < reports.length; i++){
                            if (reports[i].reportId == $(this).parent().parent().data("reportid")){
                                $(`*[data-category="${reports[i].category}"]`).parent().fadeIn();
                                $(`*[data-category="${reports[i].category}"]`).parent().addClass("selected active");
                                $(".header .title").text("Report #"+reports[i].reportId)
                                $(".header .subtitle").text("Sender is " + reports[i].reporter.name + ". ID " + reports[i].reporter.id)
                                $(".text-box-wrapper").remove()
                                $(".container").append(textBoxes)
                                $("#subject").val(reports[i].subject)
                                $("#message").val(reports[i].message)
                                $("#subject").addClass("disabled")
                                $("#message").addClass("disabled")
                                activeReport = reports[i]
                                openReport()
                            }
                        }
                    })
                })
            break;
        }
    })

    $("#deleteBtn").click(function() {
        $("body").fadeOut("fast")
        $.post(`https://${GetParentResourceName()}/close`)
        $.post(`https://${GetParentResourceName()}/deleteReport`, JSON.stringify(activeReport.reportId))
    })

    $("#concludeBtn").click(function() {
        $("body").fadeOut("fast")
        $.post(`https://${GetParentResourceName()}/close`)
        $.post(`https://${GetParentResourceName()}/concludeReport`, JSON.stringify(activeReport.reportId))
    })

    $("#gotoBtn").click(function() {
        $("body").fadeOut("fast")
        $.post(`https://${GetParentResourceName()}/close`)
        $.post(`https://${GetParentResourceName()}/goto`, JSON.stringify(activeReport.reporter.id))
        $.post(`https://${GetParentResourceName()}/concludeReport`, JSON.stringify(activeReport.reportId))
    })

    $("#bringBtn").click(function() {
        $("body").fadeOut("fast")
        $.post(`https://${GetParentResourceName()}/close`)
        $.post(`https://${GetParentResourceName()}/bring`, JSON.stringify(activeReport.reporter.id))
        $.post(`https://${GetParentResourceName()}/concludeReport`, JSON.stringify(activeReport.reportId))
    })

    $(".category").click(function(){
        $(".category").removeClass("active")
        $(this).addClass("active")
        let item = $(this).find("span")
        category = $(item).data("category")
    })

    $("#categoryBtn").click(function(){
        $(".category:not(.active)").fadeOut(300)
        setTimeout(() => {
            $("#categoryBtn").hide()
            $("#sendBtn").show()
            $("#sendBtn").css("display", "flex")
            $(".category.active").addClass("selected")
            $("#back-btn-one").fadeIn(300)
            $("#back-btn-one").css("display", "flex")
            $(".container").append(textBoxes)
            $(".container").addClass("wide")
            $("#subject").removeClass("disabled")
            $("#message").removeClass("disabled")
            $(".text-box-wrapper").fadeIn("fast")
            $(".text-box-wrapper").css("display", "flex")
            $(".header .subtitle").text("What would you like to say?")
            backType = "reporting"
        }, 100)
    })

    $("#sendBtn").click(function(){
        $("body").fadeOut(100)

        setTimeout(() => {
            $(".category.active").removeClass("selected")
            $("#back-btn-one").fadeOut(300)
            $(".text-box-wrapper").fadeOut(100)
            $(".container").removeClass("wide")
            $(".header .subtitle").text("Please select the reason for reporting.")
            $("#sendBtn").hide()
            $("#categoryBtn").show()

            let subject = $("#subject").val()
            let message = $("#message").val()
            
            $.post(`https://${GetParentResourceName()}/sendReport`, JSON.stringify({category: category, subject: subject, message: message, concluded: false}))

            setTimeout(() => {
                $(".text-box-wrapper").remove()
                $(".category:not(.active)").fadeIn(300)
            }, 100)
        }, 100)
    })

    $("#back-btn-one").click(function(){
        openReportMenu()
    })

    $("#back-btn-two").click(function(){
        openAdminMenu()
    })

    $(".close-btn").click(function(){
        $("body").fadeOut("fast")
        $.post(`https://${GetParentResourceName()}/close`)
    })

    let textBoxes = `
    <div class="text-box-wrapper">
        <div class="subject text-box">
            <div class="title">Subject</div>
            <input type="text" placeholder="Enter subject here" id="subject">
        </div>
        <div class="message text-box">
            <div class="title">Message</div>
            <textarea placeholder="Enter your message here" id="message"></textarea>
        </div>
    </div>
    `

    function openReportMenu(){
        $(".reports-wrapper").hide()
        $(".text-box-wrapper").remove()
        $("#back-btn-one").hide()
        $("#back-btn-two").hide()

        $(".container").removeClass("wide")
        $(".container").removeClass("admin-cont")
        $(".container").addClass("report-cont")
        $(".header .title").text("Welcome, " + user)
        $(".header .subtitle").text("Please select the reason for reporting.")

        $(".bottom").show()
        $(".bottom").css("display", "flex")
        $("#bringBtn, #gotoBtn, #concludeBtn, #deleteBtn, #sendBtn, #back-btn-one, #back-btn-two").hide()
        $("#categoryBtn").show();
        $("#categoryBtn").css("display", "flex");

        $(".categories").show()
        $(".category").show();
        $(".category").removeClass("selected");
        $(".category").removeClass("active");
        $(".game-bug").addClass("active");
        $("body").fadeIn("fast");
    }

    function openAdminMenu(){
        $(".reports-wrapper").show()
        $(".text-box-wrapper").remove()
        $("#back-btn-one").hide()
        $("#back-btn-two").hide()

        $(".container").addClass("wide")
        $(".container").removeClass("report-cont")
        $(".container").addClass("admin-cont")
        $(".header .title").text("Welcome, " + user)
        $(".header .subtitle").text("Here are the latest reports, solve them and make your server happy again!")

        $(".bottom").css("display", "flex")
        $(".bottom").hide()

        $(".categories").hide()
        $(".category").hide();
        $(".category").removeClass("selected");
        $(".category").removeClass("active");
        $("body").fadeIn("fast");
    }

    function openReport(){
        $(".reports-wrapper").hide()

        $(".bottom").show()
        $(".bottom").css("display", "flex")
        $("#sendBtn, #back-btn-one, #back-btn-two, #categoryBtn").hide()
        $("#back-btn-two").show()
        $("#back-btn-two").css("display", "flex")
        $("#bringBtn, #gotoBtn, #concludeBtn, #deleteBtn").show();
        $("#bringBtn, #gotoBtn, #concludeBtn, #deleteBtn").css("display", "flex");
        if (activeReport.concluded) $("#concludeBtn").addClass("disabled") 
        else $("#concludeBtn").removeClass("disabled") 
        $(".text-box-wrapper").fadeIn("fast")
        $(".categories").fadeIn("fast")
        $(".text-box-wrapper").css("display", "flex")
    }
})